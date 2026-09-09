#!/usr/bin/env python3
"""Small transactional blackboard shared by role-configured Pi workers."""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from harness_lab.pi_rpc import PiRpcController  # noqa: E402


SCHEMA = """
CREATE TABLE IF NOT EXISTS tasks(id TEXT PRIMARY KEY, role TEXT NOT NULL, prompt TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'pending', owner TEXT, result TEXT, created_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS dependencies(task_id TEXT NOT NULL, requires_task_id TEXT NOT NULL, PRIMARY KEY(task_id,requires_task_id));
CREATE TABLE IF NOT EXISTS observations(sequence INTEGER PRIMARY KEY AUTOINCREMENT, agent TEXT NOT NULL, subject TEXT NOT NULL, value TEXT NOT NULL, created_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS claims(sequence INTEGER PRIMARY KEY AUTOINCREMENT, task_id TEXT NOT NULL, agent TEXT NOT NULL, claimed_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS artifacts(sequence INTEGER PRIMARY KEY AUTOINCREMENT, task_id TEXT NOT NULL, uri TEXT NOT NULL, content TEXT NOT NULL, created_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS conflicts(sequence INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, left_value TEXT NOT NULL, right_value TEXT NOT NULL, created_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS events(sequence INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, task_id TEXT, payload TEXT NOT NULL, created_at TEXT NOT NULL);
"""


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def connect(path: Path) -> sqlite3.Connection:
    db = sqlite3.connect(path); db.row_factory = sqlite3.Row; db.executescript(SCHEMA); return db


def event(db: sqlite3.Connection, kind: str, task_id: str | None, payload: dict[str, object]) -> None:
    db.execute("INSERT INTO events(type,task_id,payload,created_at) VALUES(?,?,?,?)", (kind, task_id, json.dumps(payload), now()))


def claim_ready(db: sqlite3.Connection, role: str) -> sqlite3.Row | None:
    db.execute("BEGIN IMMEDIATE")
    row = db.execute("""
      SELECT t.* FROM tasks t WHERE t.role=? AND t.status='pending'
      AND NOT EXISTS (
        SELECT 1 FROM dependencies d JOIN tasks required ON required.id=d.requires_task_id
        WHERE d.task_id=t.id AND required.status!='completed'
      ) ORDER BY t.created_at LIMIT 1
    """, (role,)).fetchone()
    if row is None:
        db.commit(); return None
    owner = f"{role}-pi-worker"
    db.execute("UPDATE tasks SET status='running', owner=? WHERE id=? AND status='pending'", (owner, row["id"]))
    db.execute("INSERT INTO claims(task_id,agent,claimed_at) VALUES(?,?,?)", (row["id"], owner, now()))
    event(db, "task_claimed", row["id"], {"owner": owner}); db.commit()
    return db.execute("SELECT * FROM tasks WHERE id=?", (row["id"],)).fetchone()


def run_worker(db: sqlite3.Connection, role: str, cwd: Path) -> dict[str, object]:
    row = claim_ready(db, role)
    if row is None:
        return {"claimed": False, "role": role}
    shared = [dict(item) for item in db.execute("SELECT agent,subject,value FROM observations ORDER BY sequence")]
    prompt = f"Role: {role}. Task: {row['prompt']} Shared observations: {json.dumps(shared)}"
    result = PiRpcController(cwd).run(prompt)
    db.execute("BEGIN IMMEDIATE")
    db.execute("UPDATE tasks SET status='completed', result=? WHERE id=?", (result.final_text, row["id"]))
    db.execute("INSERT INTO observations(agent,subject,value,created_at) VALUES(?,?,?,?)", (f"{role}-pi-worker", row["id"], result.final_text or "", now()))
    db.execute("INSERT INTO artifacts(task_id,uri,content,created_at) VALUES(?,?,?,?)", (row["id"], f"blackboard://artifact/{row['id']}", result.final_text or "", now()))
    event(db, "task_completed", row["id"], {"result": result.final_text})
    dependents = db.execute("SELECT task_id FROM dependencies WHERE requires_task_id=?", (row["id"],)).fetchall()
    for dependent in dependents:
        blocked = db.execute("SELECT 1 FROM dependencies d JOIN tasks t ON t.id=d.requires_task_id WHERE d.task_id=? AND t.status!='completed'", (dependent["task_id"],)).fetchone()
        if blocked is None:
            event(db, "task_activated", dependent["task_id"], {"by": row["id"]})
    db.commit()
    return {"claimed": True, "task": row["id"], "role": role, "result": result.final_text, "sharedObservations": len(shared)}


def main() -> None:
    parser = argparse.ArgumentParser(); parser.add_argument("--db", type=Path, required=True)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("init")
    seed = sub.add_parser("seed")
    worker = sub.add_parser("worker"); worker.add_argument("role", choices=["researcher", "coder", "reviewer"]); worker.add_argument("--cwd", type=Path, default=Path.cwd())
    sub.add_parser("conflict-demo"); sub.add_parser("dump")
    args = parser.parse_args(); args.db.parent.mkdir(parents=True, exist_ok=True); db = connect(args.db)
    if args.command == "init":
        print(json.dumps({"initialized": str(args.db)}))
    elif args.command == "seed":
        stamp = now()
        tasks = [("research", "researcher", "Return exactly RESEARCH_READY."), ("implement", "coder", "Return exactly CODE_READY."), ("review", "reviewer", "Return exactly REVIEW_READY.")]
        db.executemany("INSERT INTO tasks(id,role,prompt,created_at) VALUES(?,?,?,?)", [(task, role, prompt, stamp) for task, role, prompt in tasks])
        db.executemany("INSERT INTO dependencies(task_id,requires_task_id) VALUES(?,?)", [("implement", "research"), ("review", "implement")])
        event(db, "task_activated", "research", {"reason": "no dependencies"}); db.commit()
    elif args.command == "worker":
        print(json.dumps(run_worker(db, args.role, args.cwd)))
    elif args.command == "conflict-demo":
        left, right = "SQLite", "JSONL"
        db.execute("INSERT INTO observations(agent,subject,value,created_at) VALUES(?,?,?,?)", ("coder", "storage-choice", left, now()))
        db.execute("INSERT INTO observations(agent,subject,value,created_at) VALUES(?,?,?,?)", ("reviewer", "storage-choice", right, now()))
        db.execute("INSERT INTO conflicts(subject,left_value,right_value,created_at) VALUES(?,?,?,?)", ("storage-choice", left, right, now()))
        event(db, "conflict_detected", None, {"subject": "storage-choice", "values": [left, right]}); db.commit()
    elif args.command == "dump":
        names = ("tasks", "dependencies", "observations", "claims", "artifacts", "conflicts", "events")
        print(json.dumps({name: [dict(row) for row in db.execute(f"SELECT * FROM {name}")] for name in names}, indent=2))


if __name__ == "__main__":
    main()
