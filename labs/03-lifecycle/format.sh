#!/usr/bin/env bash
set -euo pipefail

trace_file="${1:-}"
if [[ -z "$trace_file" || ! -f "$trace_file" ]]; then
  echo "Usage: $0 path/to/lifecycle.jsonl" >&2
  exit 1
fi

jq -r '"\(.sequence | tostring | if length == 1 then "0" + . else . end)  \(.event)\t\(.summary | tojson)"' "$trace_file"
