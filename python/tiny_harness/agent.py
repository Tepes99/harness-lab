#!/usr/bin/env python3
"""Educational OpenAI-compatible model/tool loop; deliberately not a Pi replacement."""

from __future__ import annotations

import argparse
import json
import ssl
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any


READ_TOOL = {
    "type": "function",
    "function": {
        "name": "read_file",
        "description": "Read one UTF-8 file inside the working directory.",
        "parameters": {
            "type": "object",
            "properties": {"path": {"type": "string"}},
            "required": ["path"],
            "additionalProperties": False,
        },
    },
}


def provider_config() -> dict[str, Any]:
    path = Path.home() / ".pi/agent/models.json"
    providers = json.loads(path.read_text())["providers"]
    return providers["home-vllm"]


def complete(config: dict[str, Any], messages: list[dict[str, Any]]) -> dict[str, Any]:
    payload = {
        "model": "qwen3.8-27b-fp8",
        "messages": messages,
        "tools": [READ_TOOL],
        "stream": False,
        "max_tokens": 1024,
        "chat_template_kwargs": {"enable_thinking": False},
    }
    headers = {"Content-Type": "application/json"}
    api_key = config.get("apiKey")
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"
    request = urllib.request.Request(f"{config['baseUrl'].rstrip('/')}/chat/completions", data=json.dumps(payload).encode(), headers=headers, method="POST")
    try:
        default_paths = ssl.get_default_verify_paths()
        fallback_ca = Path("/etc/ssl/cert.pem")
        context = ssl.create_default_context(cafile=str(fallback_ca) if default_paths.cafile is None and fallback_ca.exists() else None)
        with urllib.request.urlopen(request, timeout=90, context=context) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode(errors="replace")[:1000]
        raise RuntimeError(f"model request failed with HTTP {error.code}: {detail}") from error


def read_file(cwd: Path, arguments: dict[str, Any]) -> str:
    if set(arguments) != {"path"} or not isinstance(arguments["path"], str):
        raise ValueError("read_file requires exactly one string path")
    target = (cwd / arguments["path"]).resolve()
    try:
        target.relative_to(cwd.resolve())
    except ValueError as error:
        raise ValueError("path escapes working directory") from error
    return target.read_text()


def run(prompt: str, cwd: Path, *, max_turns: int = 4) -> dict[str, Any]:
    config = provider_config()
    messages: list[dict[str, Any]] = [
        {"role": "system", "content": "Use read_file when evidence is requested. Return only the requested answer."},
        {"role": "user", "content": prompt},
    ]
    trace: list[dict[str, Any]] = []
    input_tokens = output_tokens = 0
    for turn in range(1, max_turns + 1):
        response = complete(config, messages)
        usage = response.get("usage", {})
        input_tokens += usage.get("prompt_tokens", 0); output_tokens += usage.get("completion_tokens", 0)
        message = response["choices"][0]["message"]
        calls = message.get("tool_calls") or []
        trace.append({"turn": turn, "finishReason": response["choices"][0].get("finish_reason"), "toolCalls": len(calls), "usage": usage})
        if not calls:
            return {"finalText": message.get("content") or "", "turns": turn, "toolCalls": sum(item["toolCalls"] for item in trace), "inputTokens": input_tokens, "outputTokens": output_tokens, "trace": trace}
        messages.append({"role": "assistant", "content": message.get("content"), "tool_calls": calls})
        for call in calls:
            if call.get("type") != "function" or call.get("function", {}).get("name") != "read_file":
                raise ValueError(f"unsupported tool call: {call}")
            arguments = json.loads(call["function"]["arguments"])
            result = read_file(cwd, arguments)
            messages.append({"role": "tool", "tool_call_id": call["id"], "content": result})
    raise RuntimeError(f"agent exceeded {max_turns} turns")


def main() -> None:
    parser = argparse.ArgumentParser(); parser.add_argument("prompt"); parser.add_argument("--cwd", type=Path, default=Path.cwd()); parser.add_argument("--output", type=Path); args = parser.parse_args()
    result = run(args.prompt, args.cwd)
    encoded = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True); args.output.write_text(encoded)
    print(encoded, end="")


if __name__ == "__main__":
    main()
