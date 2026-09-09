#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-14/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"
"$root/harnesses/run.sh" minimal "Return exactly CATALOG_OK." >"$out/minimal.events.jsonl"
"$root/harnesses/run.sh" read-only-analyst "Read package.json and return only its package name." >"$out/read-only.events.jsonl"
jq -e 'select(.type=="message_end") | .message.content[]? | select(.type=="text" and (.text | contains("CATALOG_OK")))' "$out/minimal.events.jsonl" >/dev/null
jq -e 'select(.type=="tool_execution_end" and .toolName=="read" and .isError==false)' "$out/read-only.events.jsonl" >/dev/null
jq -e '.harnesses | length >= 10' "$root/harnesses/catalog.json" >/dev/null
echo "Catalog parsed; minimal and read-only compositions ran. Artifacts: $out"
