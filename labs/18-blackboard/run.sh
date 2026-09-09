#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-18/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"; db="$out/blackboard.sqlite"; board="$root/python/blackboard/blackboard.py"
python3 "$board" --db "$db" init >/dev/null
python3 "$board" --db "$db" seed
for role in researcher coder reviewer; do python3 "$board" --db "$db" worker "$role" --cwd "$root" >"$out/$role.json"; done
python3 "$board" --db "$db" conflict-demo
python3 "$board" --db "$db" dump >"$out/state.json"
jq -e '[.tasks[] | select(.status=="completed")] | length == 3' "$out/state.json" >/dev/null
jq -e '(.claims | length) == 3 and (.artifacts | length) == 3 and (.conflicts | length) == 1' "$out/state.json" >/dev/null
jq -e '[.events[] | select(.type=="task_activated")] | length == 3' "$out/state.json" >/dev/null
jq -e '.sharedObservations == 2 and .result == "REVIEW_READY"' "$out/reviewer.json" >/dev/null
echo "Three independent Pi roles coordinated through one transactional blackboard. Artifacts: $out"
