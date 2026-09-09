#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$lab_dir/../.." && pwd)"
out="$root/.lab-output/lab-08/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$out"
relative_supported=".lab-output/${out#"$root/.lab-output/"}/expected.txt"
printf 'receipt-ok\n' >"$out/expected.txt"
for case_name in supported unsupported; do
  export HARNESS_RECEIPTS_FILE="$out/$case_name.receipts.jsonl"
  path="$relative_supported"
  [[ "$case_name" == unsupported ]] && path=".lab-output/missing-lab-08-file.txt"
  pi --provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --no-builtin-tools --tools submit_completion --no-extensions \
    -e "$root/extensions/verification/completion-verifier.ts" --no-skills --no-prompt-templates --no-themes --no-context-files \
    --system-prompt "Call submit_completion exactly once with the supplied path. Report its grounded outcome." -- "Claim completion for path $path." >"$out/$case_name.events.jsonl"
done
jq -e 'select(.type == "VERIFICATION_PASSED")' "$out/supported.receipts.jsonl" >/dev/null
jq -e 'select(.type == "VERIFICATION_FAILED" and .evidence.reason == "missing_file")' "$out/unsupported.receipts.jsonl" >/dev/null
echo "Supported claim passed; missing-file claim was rejected. Artifacts: $out"
