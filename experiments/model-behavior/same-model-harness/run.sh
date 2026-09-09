#!/usr/bin/env bash
set -euo pipefail
experiment_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$experiment_dir/../../.." && pwd)"
out="${1:-$root/.lab-output/lab-15/$(date -u +%Y%m%dT%H%M%SZ)}"; mkdir -p "$out"
task_file="$root/evals/tasks/smoke.json"
common=(--provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --approve --no-extensions --no-prompt-templates --no-themes --no-context-files)
now_ms() { node -e 'process.stdout.write(String(Date.now()))'; }
run_case() {
  local name="$1"; shift; local started finished
  started="$(now_ms)"; "$@" </dev/null >"$out/$name.events.jsonl"; finished="$(now_ms)"
  echo $((finished - started)) >"$out/$name.duration-ms"
}

while IFS= read -r task; do
  id="$(jq -r '.id' <<<"$task")"; instruction="$(jq -r '.instruction' <<<"$task")"; expected="$(jq -r '.expected' <<<"$task")"; path="$(jq -r '.evidencePath' <<<"$task")"; expected_json="$(jq -c '.expectedContent' <<<"$task")"
  prefix="$id--"
  run_case "${prefix}minimal-pi" pi "${common[@]}" --no-tools --no-skills --system-prompt "Return only evidence you can establish with available capabilities." -- "$instruction"
  run_case "${prefix}coding" pi "${common[@]}" --tools read,grep,find,ls,bash,edit,write --no-skills --system-prompt "Use a tool to inspect evidence, then return only the answer." -- "$instruction"
  run_case "${prefix}verification" env HARNESS_RECEIPTS_FILE="$out/${prefix}verification.receipts.jsonl" pi "${common[@]}" --no-builtin-tools --tools submit_completion -e "$root/extensions/verification/completion-verifier.ts" --no-skills --system-prompt "Call submit_completion with path $path and expectedContent represented by this JSON string: $expected_json. Only after VERIFIED, return exactly $expected." -- "$instruction"

  started="$(now_ms)"
  pi "${common[@]}" --no-tools -e "$root/labs/07-plan-mode/plan-mode.ts" --plan --no-skills --system-prompt "Produce a two-step evidence-gathering plan. Do not claim the answer." -- "$instruction" </dev/null >"$out/${prefix}planner.events.jsonl"
  plan="$(node "$experiment_dir/extract-final.mjs" "$out/${prefix}planner.events.jsonl")"
  pi "${common[@]}" --tools read --no-skills --system-prompt "Execute the supplied plan with read, then return only the answer." -- "Task: $instruction Plan: $plan" </dev/null >"$out/${prefix}executor.events.jsonl"
  cat "$out/${prefix}planner.events.jsonl" "$out/${prefix}executor.events.jsonl" >"$out/${prefix}planner-executor.events.jsonl"
  finished="$(now_ms)"; echo $((finished - started)) >"$out/${prefix}planner-executor.duration-ms"

  started="$(now_ms)"
  pi "${common[@]}" --tools read --no-skills --system-prompt "Act on the task using read and return only the observed answer." -- "$instruction" </dev/null >"$out/${prefix}actor.events.jsonl"
  actor_result="$(node "$experiment_dir/extract-final.mjs" "$out/${prefix}actor.events.jsonl")"
  pi "${common[@]}" --tools read --no-skills --system-prompt "Independently inspect the evidence. Return exactly $expected only if the actor result matches it; otherwise return FAIL." -- "Task: $instruction Actor result: $actor_result" </dev/null >"$out/${prefix}verifier.events.jsonl"
  cat "$out/${prefix}actor.events.jsonl" "$out/${prefix}verifier.events.jsonl" >"$out/${prefix}actor-verifier.events.jsonl"
  finished="$(now_ms)"; echo $((finished - started)) >"$out/${prefix}actor-verifier.duration-ms"

  run_case "${prefix}multi-agent" pi "${common[@]}" --no-builtin-tools --tools delegate_reader -e "$experiment_dir/delegate-reader.ts" --no-skills --system-prompt "Delegate the evidence task exactly once, then return only the child answer." -- "$instruction"
done < <(jq -c '.tasks[]' "$task_file")
node "$experiment_dir/analyze.mjs" "$out" "$task_file"
echo "Benchmark complete. Report: $out/REPORT.md"
