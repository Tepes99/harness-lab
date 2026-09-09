#!/usr/bin/env python3
"""Small synchronous controller for Pi's strict LF-delimited RPC mode."""

from __future__ import annotations

import argparse
import json
import os
import selectors
import subprocess
import time
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


@dataclass
class RpcRun:
    final_text: str | None
    session_id: str | None
    event_count: int
    model_calls: int
    tool_calls: int
    input_tokens: int
    output_tokens: int
    elapsed_ms: int
    events: list[dict[str, Any]]


class PiRpcController:
    def __init__(self, cwd: Path, *, extra_args: list[str] | None = None) -> None:
        self.cwd = cwd.resolve()
        self.extra_args = extra_args or ["--no-tools"]

    def run(self, prompt: str, *, timeout: float = 90.0) -> RpcRun:
        command = [
            "pi", "--mode", "rpc", "--provider", "home-vllm", "--model", "qwen3.8-27b-fp8",
            "--thinking", "off", "--no-session", "--approve", "--no-extensions", *self.extra_args,
            "--no-skills", "--no-prompt-templates", "--no-themes", "--no-context-files",
            "--system-prompt", "Follow the controller task exactly and answer briefly.",
        ]
        started = time.monotonic()
        process = subprocess.Popen(command, cwd=self.cwd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        assert process.stdin is not None and process.stdout is not None

        def send(value: dict[str, Any]) -> None:
            process.stdin.write(json.dumps(value, separators=(",", ":")).encode() + b"\n")
            process.stdin.flush()

        selector = selectors.DefaultSelector()
        selector.register(process.stdout, selectors.EVENT_READ)
        send({"id": "prompt", "type": "prompt", "message": prompt})
        deadline = time.monotonic() + timeout
        buffer = b""
        events: list[dict[str, Any]] = []
        requested_final = False
        final_text: str | None = None
        final_state: dict[str, Any] | None = None
        try:
            while final_text is None or final_state is None:
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    raise TimeoutError(f"Pi RPC did not settle within {timeout:.0f}s")
                ready = selector.select(min(remaining, 1.0))
                if not ready:
                    if process.poll() is not None:
                        raise RuntimeError("Pi RPC exited before returning final state")
                    continue
                chunk = os.read(process.stdout.fileno(), 65536)
                if not chunk:
                    raise RuntimeError("Pi RPC closed stdout before returning final state")
                buffer += chunk
                while b"\n" in buffer:
                    raw, buffer = buffer.split(b"\n", 1)
                    if not raw:
                        continue
                    event = json.loads(raw)
                    events.append(event)
                    if event.get("type") == "agent_settled" and not requested_final:
                        send({"id": "final-text", "type": "get_last_assistant_text"})
                        send({"id": "final-state", "type": "get_state"})
                        requested_final = True
                    if event.get("type") == "response" and event.get("id") == "final-text":
                        if not event.get("success"):
                            raise RuntimeError(event.get("error", "get_last_assistant_text failed"))
                        final_text = event["data"]["text"]
                    if event.get("type") == "response" and event.get("id") == "final-state":
                        if not event.get("success"):
                            raise RuntimeError(event.get("error", "get_state failed"))
                        final_state = event["data"]
        finally:
            selector.close()
            process.terminate()
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()

        assistant = [event["message"] for event in events if event.get("type") == "message_end" and event.get("message", {}).get("role") == "assistant"]
        return RpcRun(
            final_text=final_text,
            session_id=final_state.get("sessionId") if final_state else None,
            event_count=len(events),
            model_calls=len(assistant),
            tool_calls=sum(1 for event in events if event.get("type") == "tool_execution_end"),
            input_tokens=sum(message.get("usage", {}).get("input", 0) for message in assistant),
            output_tokens=sum(message.get("usage", {}).get("output", 0) for message in assistant),
            elapsed_ms=round((time.monotonic() - started) * 1000),
            events=events,
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Run one task through a Pi RPC worker")
    parser.add_argument("prompt")
    parser.add_argument("--cwd", type=Path, default=Path.cwd())
    parser.add_argument("--events", type=Path)
    parser.add_argument("--summary", type=Path)
    args = parser.parse_args()
    result = PiRpcController(args.cwd).run(args.prompt)
    if args.events:
        args.events.parent.mkdir(parents=True, exist_ok=True)
        args.events.write_text("".join(json.dumps(event) + "\n" for event in result.events))
    summary = asdict(result)
    summary.pop("events")
    encoded = json.dumps(summary, indent=2) + "\n"
    if args.summary:
        args.summary.parent.mkdir(parents=True, exist_ok=True)
        args.summary.write_text(encoded)
    print(encoded, end="")


if __name__ == "__main__":
    main()
