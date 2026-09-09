#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$lab_dir/../.." && pwd)"
out="$root/.lab-output/lab-09/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$out"
export HARNESS_TELEMETRY_FILE="$out/telemetry.jsonl"
pi --provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --no-builtin-tools --tools structured_echo --no-extensions \
  -e "$root/labs/02-custom-tool/tools.ts" -e "$root/extensions/observability/telemetry.ts" --no-skills --no-prompt-templates --no-themes --no-context-files \
  --system-prompt "Use the requested tool once." -- 'Echo "observable" once, then answer.' >"$out/events.jsonl"
jq -c . "$out/telemetry.jsonl"
echo "Artifacts: $out"
