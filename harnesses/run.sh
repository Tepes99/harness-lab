#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="${1:?usage: harnesses/run.sh NAME PROMPT}"
prompt="${2:?usage: harnesses/run.sh NAME PROMPT}"
common=(--provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --approve --no-extensions --no-prompt-templates --no-themes --no-context-files)
case "$name" in
  minimal)
    pi "${common[@]}" --no-tools --no-skills --system-prompt "Answer directly and briefly." -- "$prompt" ;;
  coding)
    HARNESS_RECEIPTS_FILE="${HARNESS_RECEIPTS_FILE:-$root/.lab-output/harness-coding-receipts.jsonl}" \
      pi "${common[@]}" --tools read,grep,find,ls,bash,edit,write,submit_completion -e "$root/extensions/verification/completion-verifier.ts" --no-skills --system-prompt "Inspect, act, test, and submit completion evidence." -- "$prompt" ;;
  read-only-analyst)
    HARNESS_TOOL_POLICY=read-only pi "${common[@]}" --tools read,grep,find,ls -e "$root/extensions/policies/tool-policy.ts" --no-skills --system-prompt "Analyze from workspace evidence without mutation." -- "$prompt" ;;
  researcher)
    pi "${common[@]}" --tools read,grep,find,ls --skill "$root/skills/evidence-summary/SKILL.md" --system-prompt "Gather evidence before synthesizing." -- "$prompt" ;;
  reviewer)
    pi "${common[@]}" --tools read,grep,find,ls --skill "$root/skills/failure-boundary/SKILL.md" --system-prompt "Review the artifact and identify concrete defects." -- "$prompt" ;;
  low-context)
    pi "${common[@]}" --tools read --no-skills --system-prompt "Use the least context needed. Return only the result." -- "$prompt" ;;
  experimental)
    HARNESS_LAB_CONTEXT_FILE="${HARNESS_LAB_CONTEXT_FILE:-$root/.lab-output/experimental-context.jsonl}" \
      pi "${common[@]}" --no-tools -e "$root/extensions/observability/context-inspector.ts" --no-skills --system-prompt "Expose assumptions and treat this composition as disposable." -- "$prompt" ;;
  multi-agent)
    pi "${common[@]}" --no-builtin-tools --tools delegate_once -e "$root/labs/13-subagents/subagent.ts" --no-skills --system-prompt "Delegate exactly once, then return the child result." -- "$prompt" ;;
  planner-executor|actor-verifier|autonomous)
    echo "$name is a multi-stage composition; use its architecture document and experiment runner." >&2
    exit 2 ;;
  *) echo "unknown harness: $name" >&2; exit 2 ;;
esac
