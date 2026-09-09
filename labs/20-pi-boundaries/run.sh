#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-20/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"
python3 "$root/experiments/pi-boundaries/probe.py" --root "$root" --output "$out/report.json" >"$out/stdout.json"
jq -e '.parallelProcesses==2 and .distinctSessions==2 and .externalStateRows==2' "$out/report.json" >/dev/null
jq -e '[.workers[] | select(.expected==.finalText and .streamUpdates>0)] | length==2' "$out/report.json" >/dev/null
for area in 'Session model' 'Context lifecycle' Concurrency 'Extension API' Orchestration 'Model routing' Durability Observability 'External state' Streaming Parallelism 'Subprocess control'; do rg -q "\| $area \|" "$root/docs/pi-internals/boundaries.md"; done
echo "Concurrent isolated Pi workers passed; twelve boundaries classified. Artifacts: $out"
