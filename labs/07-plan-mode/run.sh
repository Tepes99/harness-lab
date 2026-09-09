#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; repo_root="$(cd "$lab_dir/../.." && pwd)"
out="$repo_root/.lab-output/lab-07/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"
export HARNESS_LAB_POLICY_MARKER="$out/should-not-exist.txt" HARNESS_LAB_CONTEXT_FILE="$out/context.jsonl"
pi --provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --no-builtin-tools --tools lab_write_marker --no-extensions \
  -e "$repo_root/labs/06-tool-policy/capability.ts" -e "$lab_dir/plan-mode.ts" -e "$repo_root/extensions/observability/context-inspector.ts" \
  --plan --no-skills --no-prompt-templates --no-themes --no-context-files --system-prompt "Respect active harness modes." \
  -- "Plan how to create a marker containing PLAN_TEST. Return exactly two numbered steps." >"$out/events.jsonl"
[[ ! -f "$out/should-not-exist.txt" ]]; jq -e 'select(.stage == "pi_context") | [.data.messages[] | select(.role == "custom" and .customType == "lab-07-plan-context")] | length == 1' "$out/context.jsonl" >/dev/null
echo "Plan context injected; mutation artifact absent. Artifacts: $out"
