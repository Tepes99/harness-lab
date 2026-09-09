#!/usr/bin/env bash
set -euo pipefail

lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$lab_dir/../.." && pwd)"
run_stamp="$(date -u +%Y%m%dT%H%M%SZ)"
output_dir="$repo_root/.lab-output/lab-05/$run_stamp"
prompt="Respond with the single uppercase marker requested by any experiment context you receive. If no marker is present, respond exactly NO_MARKER."
mkdir -p "$output_dir"

run_case() {
  local case_name="$1"
  local with_injection="$2"
  local pi_args=(
    --provider home-vllm
    --model qwen3.8-27b-fp8
    --thinking off
    --mode json
    --print
    --no-session
    --no-tools
    --no-extensions
  )

  export HARNESS_LAB_CONTEXT_FILE="$output_dir/$case_name.context.jsonl"
  if [[ "$with_injection" == "yes" ]]; then
    export HARNESS_LAB_CONTEXT_MARKER="INJECTION_SEEN"
    pi_args+=(--extension "$lab_dir/inject-context.ts")
  else
    unset HARNESS_LAB_CONTEXT_MARKER || true
  fi
  pi_args+=(
    --extension "$repo_root/extensions/observability/context-inspector.ts"
    --no-skills
    --no-prompt-templates
    --no-themes
    --no-context-files
    --system-prompt "You are participating in a controlled context experiment. Follow the user's response-format request."
    -- "$prompt"
  )

  pi "${pi_args[@]}" >"$output_dir/$case_name.pi-events.jsonl"
}

run_case baseline no
run_case injected yes

"$lab_dir/compare.sh" "$output_dir"
echo
echo "Lab 5 artifacts: $output_dir"
