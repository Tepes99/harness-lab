#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-17/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"; db="$out/tasks.sqlite"; runner="$root/python/autonomy/task_runner.py"
python3 "$runner" --db "$db" init >/dev/null
python3 "$runner" --db "$db" add durable-task "Reply exactly DURABLE_OK." --max-attempts 2
python3 "$runner" --db "$db" pause durable-task
python3 "$runner" --db "$db" resume durable-task
python3 "$runner" --db "$db" checkpoint durable-task queued
python3 "$runner" --db "$db" claim-only durable-task --lease-seconds -1 >"$out/crashed-claim.json"
python3 "$runner" --db "$db" recover >"$out/recovery.json"
python3 "$runner" --db "$db" run-one --id durable-task --cwd "$root" >"$out/completion.json"
python3 "$runner" --db "$db" add blocker-demo "Reply exactly UNBLOCKED_OK."
python3 "$runner" --db "$db" block blocker-demo waiting-for-signal
python3 "$runner" --db "$db" signal unblock:blocker-demo '{"source":"lab"}'
python3 "$runner" --db "$db" dump >"$out/state.json"
jq -e '.tasks[] | select(.id=="durable-task" and .status=="completed" and .attempts==2 and .result=="DURABLE_OK")' "$out/state.json" >/dev/null
jq -e '.tasks[] | select(.id=="blocker-demo" and .status=="pending" and .blocker==null)' "$out/state.json" >/dev/null
for kind in task_paused task_resumed checkpoint_saved lease_expired task_completed external_event_unblocked; do jq -e --arg kind "$kind" '.events[] | select(.type==$kind)' "$out/state.json" >/dev/null; done
echo "Expired lease recovered; retry completed; external event cleared blocker. Artifacts: $out"
