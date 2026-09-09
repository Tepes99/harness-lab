#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$lab_dir/../.." && pwd)"
run_stamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_dir="$repo_root/.lab-output/lab-02/$run_stamp"
mkdir -p "$output_dir"

run_case() {
  local case_name="$1"
  local prompt="$2"
  export HARNESS_LAB_TRACE_FILE="$output_dir/$case_name.request.trace.jsonl"

  pi \
    --provider home-vllm \
    --model qwen3.8-27b-fp8 \
    --thinking off \
    --mode json \
    --print \
    --no-session \
    --no-builtin-tools \
    --tools structured_echo,workspace_inventory \
    --no-extensions \
    --extension "$lab_dir/tools.ts" \
    --extension "$repo_root/labs/01-minimal-pi/request-recorder.ts" \
    --no-skills \
    --no-prompt-templates \
    --no-themes \
    --no-context-files \
    --system-prompt "You are running a tool-protocol experiment. Follow the requested tool-call sequence exactly and report only grounded tool results." \
    -- "$prompt" | tee "$output_dir/$case_name.pi-events.jsonl"
}

run_case \
  "echo" \
  'Call structured_echo exactly once with message "hello from qwen" and repeat 2. After it returns, output only the JSON returned by the tool.'

run_case \
  "inventory" \
  'Call workspace_inventory exactly once with path "labs" and maxDepth 1. Then report the fileCount and directoryCount from its result in one sentence.'

echo
echo "Lab 2 artifacts: $output_dir"
