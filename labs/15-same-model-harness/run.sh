#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-15/$(date -u +%Y%m%dT%H%M%SZ)"
"$root/experiments/model-behavior/same-model-harness/run.sh" "$out"
jq -e '.rows | length == 6' "$out/results.json" >/dev/null
jq -e '[.rows[].configuration] == ["minimal-pi","coding","verification","planner-executor","actor-verifier","multi-agent"]' "$out/results.json" >/dev/null
jq -e '.observations | length == 18' "$out/results.json" >/dev/null
echo "Six Qwen harness configurations measured. Artifacts: $out"
