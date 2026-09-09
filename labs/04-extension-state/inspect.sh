#!/usr/bin/env bash
set -euo pipefail

run_dir="${1:-}"
if [[ -z "$run_dir" || ! -d "$run_dir" ]]; then
  echo "Usage: $0 path/to/lab-04-run" >&2
  exit 1
fi

echo "Extension instance/restoration audit:"
jq -c '{event, instanceId, action, state, restoredFromEntryId, branchEntryCount}' "$run_dir/state-audit.jsonl"

echo
echo "Persisted extension entries and tool snapshots:"
session_file="$(find "$run_dir/sessions" -name '*.jsonl' -type f | head -n 1)"
jq -c 'select((.type == "custom" and .customType == "lab-04-counter-audit") or (.type == "message" and .message.role == "toolResult" and .message.toolName == "lab_counter"))' "$session_file"
