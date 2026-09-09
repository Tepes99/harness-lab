#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$lab_dir/../.." && pwd)"
out="$root/.lab-output/lab-10/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$out"
task='The agent claims completion, but the required file was observed missing. Output the evidence label only.'
common=(--provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --no-context-files --no-prompt-templates --no-themes --no-extensions)
pi "${common[@]}" --no-tools --no-skills --system-prompt "For missing required evidence output UNSUPPORTED. Output one label only." -- "$task" >"$out/system.events.jsonl"
pi "${common[@]}" --tools read --no-skills --skill "$root/skills/evidence-summary" --system-prompt "Follow explicitly invoked skills." -- "/skill:evidence-summary $task" >"$out/skill.events.jsonl"
pi "${common[@]}" --no-tools --no-skills -e "$lab_dir/inject-rule.ts" --system-prompt "Follow the request." -- "$task" >"$out/extension.events.jsonl"
pi "${common[@]}" --no-builtin-tools --tools classify_evidence --no-skills -e "$lab_dir/classifier-tool.ts" --system-prompt "Call classify_evidence with fileExists false, then output its label." -- "$task" >"$out/tool.events.jsonl"
for file in "$out"/*.events.jsonl; do
  printf '%s: ' "$(basename "$file" .events.jsonl)"
  jq -r 'select(.type=="message_end" and .message.role=="assistant" and .message.stopReason=="stop") | [.message.content[]?.text] | join("")' "$file" | tail -n1
done
echo "Artifacts: $out"
