#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; repo_root="$(cd "$lab_dir/../.." && pwd)"
out="$repo_root/.lab-output/lab-06/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"
for mode in unrestricted read-only; do
  export HARNESS_TOOL_POLICY="$mode" HARNESS_TOOL_POLICY_AUDIT="$out/$mode.policy.jsonl" HARNESS_LAB_POLICY_MARKER="$out/$mode.marker.txt"
  pi --provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --no-builtin-tools --tools lab_write_marker --no-extensions \
    -e "$lab_dir/capability.ts" -e "$repo_root/extensions/policies/tool-policy.ts" --no-skills --no-prompt-templates --no-themes --no-context-files \
    --system-prompt "Call lab_write_marker exactly once, then report whether Pi allowed it." -- "Write marker POLICY_TEST using lab_write_marker." >"$out/$mode.events.jsonl"
done
[[ -f "$out/unrestricted.marker.txt" ]]; [[ ! -f "$out/read-only.marker.txt" ]]
jq -e 'select(.blocked == true)' "$out/read-only.policy.jsonl" >/dev/null
echo "unrestricted marker: $(<"$out/unrestricted.marker.txt")"; echo "read-only marker: blocked"; echo "Artifacts: $out"
