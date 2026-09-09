#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${1:-$(find "$repo_root/.lab-output/lab-02" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n 1)}"

if [[ -z "$run_dir" || ! -d "$run_dir" ]]; then
  echo "No Lab 2 run found." >&2
  exit 1
fi

echo "Run: $run_dir"
for event_file in "$run_dir"/*.pi-events.jsonl; do
  echo
  echo "$(basename "$event_file")"
  jq -c 'select(.type == "tool_execution_start" or .type == "tool_execution_end" or .type == "turn_end") | if .type == "turn_end" then {type, toolResultCount: (.toolResults | length), stopReason: .message.stopReason} else . end' "$event_file"
done
