#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-21/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"
python3 "$root/python/tiny_harness/agent.py" "Read labs/21-tiny-harness/fixture.txt and return exactly its token." --cwd "$root" --output "$out/result.json" >"$out/stdout.json"
jq -e '.finalText=="TINY_OK" and .toolCalls==1 and .turns==2' "$out/result.json" >/dev/null
echo "Tiny direct model/tool loop completed in two turns. Artifacts: $out"
