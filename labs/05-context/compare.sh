#!/usr/bin/env bash
set -euo pipefail

run_dir="${1:-}"
if [[ -z "$run_dir" || ! -d "$run_dir" ]]; then
  echo "Usage: $0 path/to/lab-05-run" >&2
  exit 1
fi

for case_name in baseline injected; do
  trace="$run_dir/$case_name.context.jsonl"
  events="$run_dir/$case_name.pi-events.jsonl"
  echo "$case_name"
  jq -s '{
    systemPromptCharacters: ([.[] | select(.stage == "system_prompt") | .data.finalSystemPromptCharacters][0]),
    piContext: ([.[] | select(.stage == "pi_context") | {messageCount: .data.messageCount, messagesBySource: .data.messagesBySource}][0]),
    providerMessages: ([.[] | select(.stage == "provider_payload") | .data.payload.messages][0]),
    providerReportedInputTokens: ([.[] | select(.stage == "assistant_usage") | .data.usage.input] | last)
  }' "$trace"
  jq -r 'select(.type == "message_end" and .message.role == "assistant" and .message.stopReason == "stop") | "assistant: " + ([.message.content[] | select(.type == "text") | .text] | join(""))' "$events"
  echo
done
