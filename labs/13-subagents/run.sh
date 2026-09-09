#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-13/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"
pi --provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --no-builtin-tools --tools delegate_once --no-extensions -e "$lab_dir/subagent.ts" --no-skills --no-prompt-templates --no-themes --no-context-files --system-prompt "Delegate the requested task exactly once, then return the child result." -- 'Ask the child to compute 6 * 7 and return only the number.' >"$out/events.jsonl"
jq -e 'select(.type=="tool_execution_end" and .toolName=="delegate_once" and .isError==false)' "$out/events.jsonl" >/dev/null
echo "Child Pi completed through parent tool. Artifacts: $out"
