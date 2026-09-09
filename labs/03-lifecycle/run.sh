#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$lab_dir/../.." && pwd)"
run_stamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_dir="$repo_root/.lab-output/lab-03/$run_stamp"
mkdir -p "$output_dir"

export HARNESS_LAB_LIFECYCLE_FILE="$output_dir/lifecycle.jsonl"

pi \
  --provider home-vllm \
  --model qwen3.8-27b-fp8 \
  --thinking off \
  --mode json \
  --print \
  --no-session \
  --no-builtin-tools \
  --tools structured_echo \
  --no-extensions \
  --extension "$repo_root/labs/02-custom-tool/tools.ts" \
  --extension "$repo_root/extensions/observability/lifecycle-trace.ts" \
  --no-skills \
  --no-prompt-templates \
  --no-themes \
  --no-context-files \
  --system-prompt "Call the requested tool exactly once, then answer from its result." \
  -- 'Call structured_echo with message "trace me". Then answer exactly: TRACE_COMPLETE' \
  >"$output_dir/pi-events.jsonl"

"$lab_dir/format.sh" "$output_dir/lifecycle.jsonl"
echo
echo "Lab 3 artifacts: $output_dir"
