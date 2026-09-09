#!/usr/bin/env python3
"""Render orchestration graphs and run one routed Pi worker."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from harness_lab.pi_rpc import PiRpcController  # noqa: E402


def load_catalog(root: Path) -> dict[str, dict[str, object]]:
    return json.loads((root / "orchestrations/catalog.json").read_text())


def describe(catalog: dict[str, dict[str, object]]) -> dict[str, object]:
    events = []
    for name, definition in catalog.items():
        events.append({"type": "architecture_started", "architecture": name, "workers": definition["workers"]})
        for source, target in definition["edges"]:
            events.append({"type": "communication_edge", "architecture": name, "source": source, "target": target})
        events.append({"type": "architecture_ready", "architecture": name, "state": definition["state"]})
    return {"architectureCount": len(catalog), "architectures": list(catalog), "events": events}


def route(task: str) -> str:
    lowered = task.lower()
    if "review" in lowered or "audit" in lowered:
        return "reviewer"
    if "research" in lowered or "find" in lowered:
        return "researcher"
    return "coder"


def main() -> None:
    parser = argparse.ArgumentParser(); parser.add_argument("--root", type=Path, required=True)
    sub = parser.add_subparsers(dest="command", required=True)
    describe_command = sub.add_parser("describe"); describe_command.add_argument("--output", type=Path)
    live = sub.add_parser("live-router"); live.add_argument("task"); live.add_argument("--expected", required=True)
    args = parser.parse_args(); catalog = load_catalog(args.root)
    if args.command == "describe":
        result = describe(catalog); encoded = json.dumps(result, indent=2) + "\n"
        if args.output:
            args.output.parent.mkdir(parents=True, exist_ok=True); args.output.write_text(encoded)
        print(encoded, end="")
    else:
        role = route(args.task)
        result = PiRpcController(args.root).run(f"You are the selected {role} worker. {args.task} Return exactly {args.expected}.")
        print(json.dumps({"architecture": "specialist-router", "selectedRole": role, "finalText": result.final_text, "modelCalls": result.model_calls, "events": result.event_count}))


if __name__ == "__main__":
    main()
