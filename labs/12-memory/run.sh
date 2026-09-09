#!/usr/bin/env bash
set -euo pipefail
lab_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; root="$(cd "$lab_dir/../.." && pwd)"; out="$root/.lab-output/lab-12/$(date -u +%Y%m%dT%H%M%SZ)"; mkdir -p "$out"
export HARNESS_LOCAL_MEMORY_DB="$out/local.sqlite" HARNESS_MEMORY_SERVICE="http://127.0.0.1:18765"
python3 "$lab_dir/memory_service.py" 18765 "$out/service.sqlite" & service_pid=$!; trap 'kill "$service_pid" 2>/dev/null || true' EXIT
sleep 0.3
common=(--provider home-vllm --model qwen3.8-27b-fp8 --thinking off --mode json --print --no-session --no-builtin-tools --no-extensions --no-skills --no-prompt-templates --no-themes --no-context-files)
pi "${common[@]}" --tools local_memory -e "$lab_dir/sqlite-memory.ts" --system-prompt "Use local_memory exactly once." -- 'Put key color with value amber.' >"$out/local.events.jsonl"
pi "${common[@]}" --tools service_memory -e "$lab_dir/service-tool.ts" --system-prompt "Use service_memory exactly once." -- 'Put key color with value violet.' >"$out/service.events.jsonl"
local_value="$(python3 -c 'import sqlite3,sys; print(sqlite3.connect(sys.argv[1]).execute("select value from memory where key=?",("color",)).fetchone()[0])' "$out/local.sqlite")"
service_value="$(python3 -c 'import sqlite3,sys; print(sqlite3.connect(sys.argv[1]).execute("select value from memory where key=?",("color",)).fetchone()[0])' "$out/service.sqlite")"
[[ "$local_value" == amber && "$service_value" == violet ]]
echo "extension SQLite: $local_value; external service SQLite: $service_value. Artifacts: $out"
