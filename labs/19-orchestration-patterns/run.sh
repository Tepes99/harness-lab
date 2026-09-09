#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-19/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"; prototype="$root/python/orchestration/prototype.py"
python3 "$prototype" --root "$root" describe --output "$out/topologies.json" >/dev/null
python3 "$prototype" --root "$root" live-router "Review this bounded artifact." --expected ROUTER_OK >"$out/live-router.json"
jq -e '.architectureCount == 9 and (.architectures | length) == 9' "$out/topologies.json" >/dev/null
jq -e '.selectedRole == "reviewer" and .finalText == "ROUTER_OK"' "$out/live-router.json" >/dev/null
for document in "$root"/orchestrations/*/ARCHITECTURE.md; do
  for heading in STRUCTURE 'STATE TOPOLOGY' 'COMMUNICATION TOPOLOGY' ADVANTAGES 'FAILURE MODES' 'TOKEN COST' LATENCY 'BEST USE CASE'; do rg -q "^## $heading$" "$document"; done
done
[[ "$(find "$root/orchestrations" -name ARCHITECTURE.md | wc -l | tr -d ' ')" == 9 ]]
echo "Nine structural orchestration prototypes documented; routed Pi worker passed. Artifacts: $out"
