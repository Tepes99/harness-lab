#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$lab_dir/../.." && pwd)"
out="$root/.lab-output/lab-11/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$out/sessions"
session_id="$(uuidgen | tr '[:upper:]' '[:lower:]')"
export HARNESS_COMPACTION_TRACE="$out/compaction.jsonl"
filler=""
for _index in {1..12000}; do filler+=" archival-detail"; done
for prompt in "Remember codeword ORBIT-731. Reply ACK." "Unresolved requirement: retain receipts. Reply ACK." "The latest status is checkpoint ready.$filler Reply ACK."; do
  (cd "$lab_dir/workspace" && pi --provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --session-id "$session_id" --session-dir "$out/sessions" --approve --no-tools --no-extensions -e "$lab_dir/observe-compaction.ts" --no-skills --no-prompt-templates --no-themes --no-context-files --system-prompt "Reply briefly." -- "$prompt") >>"$out/messages.events.jsonl"
done
(cd "$lab_dir/workspace" && node "$lab_dir/compact-client.mjs" "$session_id" "$out/sessions" "$lab_dir/observe-compaction.ts" "$out/rpc.jsonl")
jq -c . "$out/compaction.jsonl"
jq -e 'select(.type=="compaction")' "$(find "$out/sessions" -name '*.jsonl' | head -n1)" >/dev/null
echo "Compaction entry persisted. Artifacts: $out"
