#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
trace_file="${1:-$(find "$repo_root/.lab-output/lab-01" -name '*.trace.jsonl' -type f 2>/dev/null | sort | tail -n 1)}"

if [[ -z "$trace_file" || ! -f "$trace_file" ]]; then
  echo "No trace found. Run labs/01-minimal-pi/run.sh first." >&2
  exit 1
fi

echo "Trace: $trace_file"
jq -r '[.timestamp, .event] | @tsv' "$trace_file"

echo
echo "Final provider payload:"
jq 'select(.event == "before_provider_request") | .data.payload' "$trace_file"

