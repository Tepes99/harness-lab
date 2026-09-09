#!/usr/bin/env python3
"""Probe process concurrency, streaming RPC, isolation, and external shared state."""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "python"))
from harness_lab.pi_rpc import PiRpcController  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(); parser.add_argument("--root", type=Path, required=True); parser.add_argument("--output", type=Path, required=True); args = parser.parse_args()
    cases = [("BOUNDARY_ALPHA", "Reply exactly BOUNDARY_ALPHA."), ("BOUNDARY_BETA", "Reply exactly BOUNDARY_BETA.")]
    started = time.monotonic()
    with ThreadPoolExecutor(max_workers=2) as pool:
        results = list(pool.map(lambda case: PiRpcController(args.root).run(case[1]), cases))
    wall_ms = round((time.monotonic() - started) * 1000)

    state_path = args.output.parent / "external-state.sqlite"
    db = sqlite3.connect(state_path)
    db.execute("CREATE TABLE worker_results(session_id TEXT PRIMARY KEY, result TEXT NOT NULL)")
    db.executemany("INSERT INTO worker_results VALUES(?,?)", [(result.session_id, result.final_text) for result in results]); db.commit()
    shared_rows = db.execute("SELECT COUNT(*) FROM worker_results").fetchone()[0]

    report = {
        "parallelProcesses": len(results),
        "wallMs": wall_ms,
        "sumWorkerMs": sum(result.elapsed_ms for result in results),
        "distinctSessions": len({result.session_id for result in results}),
        "externalStateRows": shared_rows,
        "workers": [
            {
                "expected": expected,
                "finalText": result.final_text,
                "sessionId": result.session_id,
                "eventCount": result.event_count,
                "streamUpdates": sum(1 for event in result.events if event.get("type") == "message_update"),
                "elapsedMs": result.elapsed_ms,
            }
            for (expected, _), result in zip(cases, results, strict=True)
        ],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True); args.output.write_text(json.dumps(report, indent=2) + "\n"); print(json.dumps(report))


if __name__ == "__main__":
    main()
