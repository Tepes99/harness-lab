#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$lab_dir/../.." && pwd)"
run_stamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_dir="$repo_root/.lab-output/lab-04/$run_stamp"
session_dir="$output_dir/sessions"
session_id="$(uuidgen | tr '[:upper:]' '[:lower:]')"
mkdir -p "$session_dir"

export HARNESS_LAB_STATE_AUDIT="$output_dir/state-audit.jsonl"

run_pi() {
  local prompt="$1"
  local event_file="$2"
  export HARNESS_LAB_TRACE_FILE="${event_file%.pi-events.jsonl}.request.trace.jsonl"
  pi \
    --provider home-vllm \
    --model qwen3.8-27b-fp8 \
    --thinking off \
    --mode json \
    --print \
    --session-id "$session_id" \
    --session-dir "$session_dir" \
    --no-builtin-tools \
    --tools lab_counter \
    --no-extensions \
    --extension "$lab_dir/counter.ts" \
    --extension "$repo_root/labs/01-minimal-pi/request-recorder.ts" \
    --no-skills \
    --no-prompt-templates \
    --no-themes \
    --no-context-files \
    --system-prompt "Use lab_counter exactly as requested. Ground the final answer in its returned count." \
    -- "$prompt" >"$event_file"
}

run_pi \
  'Call lab_counter once with action "increment" and amount 7. Then state the returned count.' \
  "$output_dir/01-increment.pi-events.jsonl"

run_pi \
  'Call lab_counter once with action "read". Then state the returned count.' \
  "$output_dir/02-read-after-restart.pi-events.jsonl"

"$lab_dir/inspect.sh" "$output_dir"
echo
echo "Lab 4 artifacts: $output_dir"
