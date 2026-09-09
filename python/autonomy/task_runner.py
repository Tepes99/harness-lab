#!/usr/bin/env python3
"""Durable SQLite task queue that leases bounded Pi RPC workers."""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from dataclasses import asdict
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from harness_lab.pi_rpc import PiRpcController  # noqa: E402


SCHEMA = """
CREATE TABLE IF NOT EXISTS tasks (
  id TEXT PRIMARY KEY, prompt TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'pending',
  attempts INTEGER NOT NULL DEFAULT 0, max_attempts INTEGER NOT NULL DEFAULT 3,
  checkpoint TEXT, blocker TEXT, lease_owner TEXT, lease_expires_at TEXT,
  result TEXT, last_error TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS events (
  sequence INTEGER PRIMARY KEY AUTOINCREMENT, task_id TEXT, type TEXT NOT NULL,
  payload TEXT NOT NULL, created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS external_events (
  sequence INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, payload TEXT NOT NULL,
  created_at TEXT NOT NULL
);
"""


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def connect(path: Path) -> sqlite3.Connection:
    db = sqlite3.connect(path)
    db.row_factory = sqlite3.Row
    db.executescript(SCHEMA)
    return db


def emit(db: sqlite3.Connection, task_id: str | None, kind: str, payload: dict[str, object]) -> None:
    db.execute("INSERT INTO events(task_id,type,payload,created_at) VALUES(?,?,?,?)", (task_id, kind, json.dumps(payload), now()))


def claim(db: sqlite3.Connection, worker: str, lease_seconds: int, task_id: str | None = None) -> sqlite3.Row | None:
    db.execute("BEGIN IMMEDIATE")
    query = "SELECT * FROM tasks WHERE status='pending' AND blocker IS NULL AND attempts < max_attempts"
    params: tuple[object, ...] = ()
    if task_id:
        query += " AND id=?"
        params = (task_id,)
    query += " ORDER BY created_at LIMIT 1"
    row = db.execute(query, params).fetchone()
    if row is None:
        db.commit()
        return None
    expires = (datetime.now(timezone.utc) + timedelta(seconds=lease_seconds)).isoformat()
    db.execute("UPDATE tasks SET status='running', attempts=attempts+1, lease_owner=?, lease_expires_at=?, updated_at=? WHERE id=?", (worker, expires, now(), row["id"]))
    emit(db, row["id"], "task_claimed", {"worker": worker, "leaseExpiresAt": expires})
    db.commit()
    return db.execute("SELECT * FROM tasks WHERE id=?", (row["id"],)).fetchone()


def recover(db: sqlite3.Connection) -> int:
    rows = db.execute("SELECT * FROM tasks WHERE status='running' AND lease_expires_at <= ?", (now(),)).fetchall()
    for row in rows:
        status = "pending" if row["attempts"] < row["max_attempts"] else "failed"
        db.execute("UPDATE tasks SET status=?, lease_owner=NULL, lease_expires_at=NULL, last_error='worker lease expired', updated_at=? WHERE id=?", (status, now(), row["id"]))
        emit(db, row["id"], "lease_expired", {"nextStatus": status, "attempts": row["attempts"]})
    db.commit()
    return len(rows)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--db", type=Path, required=True)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("init")
    add = sub.add_parser("add"); add.add_argument("id"); add.add_argument("prompt"); add.add_argument("--max-attempts", type=int, default=3)
    for name in ("pause", "resume"):
        command = sub.add_parser(name); command.add_argument("id")
    checkpoint = sub.add_parser("checkpoint"); checkpoint.add_argument("id"); checkpoint.add_argument("value")
    block = sub.add_parser("block"); block.add_argument("id"); block.add_argument("reason")
    signal = sub.add_parser("signal"); signal.add_argument("name"); signal.add_argument("payload", nargs="?", default="{}")
    claim_only = sub.add_parser("claim-only"); claim_only.add_argument("id"); claim_only.add_argument("--lease-seconds", type=int, default=30)
    sub.add_parser("recover")
    run_one = sub.add_parser("run-one"); run_one.add_argument("--id"); run_one.add_argument("--cwd", type=Path, default=Path.cwd())
    sub.add_parser("dump")
    args = parser.parse_args()
    args.db.parent.mkdir(parents=True, exist_ok=True)
    db = connect(args.db)
    stamp = now()

    if args.command == "init":
        print(json.dumps({"initialized": str(args.db)}))
    elif args.command == "add":
        db.execute("INSERT INTO tasks(id,prompt,max_attempts,created_at,updated_at) VALUES(?,?,?,?,?)", (args.id, args.prompt, args.max_attempts, stamp, stamp))
        emit(db, args.id, "task_added", {"maxAttempts": args.max_attempts}); db.commit()
    elif args.command == "pause":
        db.execute("UPDATE tasks SET status='paused', updated_at=? WHERE id=? AND status IN ('pending','blocked')", (stamp, args.id)); emit(db, args.id, "task_paused", {}); db.commit()
    elif args.command == "resume":
        db.execute("UPDATE tasks SET status=CASE WHEN blocker IS NULL THEN 'pending' ELSE 'blocked' END, updated_at=? WHERE id=? AND status='paused'", (stamp, args.id)); emit(db, args.id, "task_resumed", {}); db.commit()
    elif args.command == "checkpoint":
        db.execute("UPDATE tasks SET checkpoint=?, updated_at=? WHERE id=?", (args.value, stamp, args.id)); emit(db, args.id, "checkpoint_saved", {"value": args.value}); db.commit()
    elif args.command == "block":
        db.execute("UPDATE tasks SET status='blocked', blocker=?, updated_at=? WHERE id=?", (args.reason, stamp, args.id)); emit(db, args.id, "task_blocked", {"reason": args.reason}); db.commit()
    elif args.command == "signal":
        db.execute("INSERT INTO external_events(name,payload,created_at) VALUES(?,?,?)", (args.name, args.payload, stamp))
        if args.name.startswith("unblock:"):
            task_id = args.name.split(":", 1)[1]
            db.execute("UPDATE tasks SET status='pending', blocker=NULL, updated_at=? WHERE id=? AND status='blocked'", (stamp, task_id))
            emit(db, task_id, "external_event_unblocked", {"name": args.name})
        db.commit()
    elif args.command == "claim-only":
        row = claim(db, "simulated-crashed-worker", args.lease_seconds, args.id)
        print(json.dumps(dict(row) if row else None))
    elif args.command == "recover":
        print(json.dumps({"recovered": recover(db)}))
    elif args.command == "run-one":
        recover(db)
        row = claim(db, "python-runner", 120, args.id)
        if row is None:
            print(json.dumps({"claimed": False}))
        else:
            try:
                result = PiRpcController(args.cwd).run(row["prompt"])
                checkpoint_value = f"agent_settled:{result.event_count}"
                db.execute("UPDATE tasks SET status='completed', result=?, checkpoint=?, lease_owner=NULL, lease_expires_at=NULL, updated_at=? WHERE id=?", (result.final_text, checkpoint_value, now(), row["id"]))
                emit(db, row["id"], "task_completed", {"result": result.final_text, "checkpoint": checkpoint_value, "usage": {"input": result.input_tokens, "output": result.output_tokens}})
                db.commit()
                print(json.dumps({"task": row["id"], "run": {k: v for k, v in asdict(result).items() if k != "events"}}))
            except Exception as error:
                current = db.execute("SELECT attempts,max_attempts FROM tasks WHERE id=?", (row["id"],)).fetchone()
                status = "pending" if current["attempts"] < current["max_attempts"] else "failed"
                db.execute("UPDATE tasks SET status=?, last_error=?, lease_owner=NULL, lease_expires_at=NULL, updated_at=? WHERE id=?", (status, str(error), now(), row["id"]))
                emit(db, row["id"], "task_attempt_failed", {"error": str(error), "nextStatus": status}); db.commit(); raise
    elif args.command == "dump":
        print(json.dumps({"tasks": [dict(row) for row in db.execute("SELECT * FROM tasks ORDER BY created_at")], "events": [dict(row) for row in db.execute("SELECT * FROM events ORDER BY sequence")], "externalEvents": [dict(row) for row in db.execute("SELECT * FROM external_events ORDER BY sequence")]}, indent=2))


if __name__ == "__main__":
    main()
