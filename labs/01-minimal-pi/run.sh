#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$lab_dir/../.." && pwd)"
run_stamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_dir="$repo_root/.lab-output/lab-01"
trace_file="$output_dir/$run_stamp.trace.jsonl"
events_file="$output_dir/$run_stamp.pi-events.jsonl"
prompt="${*:-Reply with exactly: QWEN_LAB_1_OK}"

mkdir -p "$output_dir"

export HARNESS_LAB_TRACE_FILE="$trace_file"

pi \
  --provider home-vllm \
  --model qwen3.8-27b-fp8 \
  --thinking off \
  --mode json \
  --print \
  --no-session \
  --no-tools \
  --no-extensions \
  --extension "$lab_dir/request-recorder.ts" \
  --no-skills \
  --no-prompt-templates \
  --no-themes \
  --no-context-files \
  --system-prompt "$(<"$lab_dir/minimal-system-prompt.txt")" \
  -- "$prompt" | tee "$events_file"

echo
echo "Pi event stream: $events_file"
echo "Request trace:    $trace_file"

