#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-16/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"
python3 "$root/python/harness_lab/pi_rpc.py" "Reply exactly PYTHON_RPC_OK." --cwd "$root" --events "$out/events.jsonl" --summary "$out/summary.json" >"$out/stdout.json"
jq -e '.final_text == "PYTHON_RPC_OK" and .model_calls == 1 and .event_count > 5' "$out/summary.json" >/dev/null
jq -e 'select(.type=="response" and .command=="prompt" and .success==true)' "$out/events.jsonl" >/dev/null
jq -e 'select(.type=="agent_settled")' "$out/events.jsonl" >/dev/null
echo "Python drove Pi over RPC and tracked its result. Artifacts: $out"
