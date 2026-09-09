# Qwen findings

## 2026-09-09 — Minimal exact-response smoke test

- Harness: Lab 1 with no tools, no persisted session, no discovered resources, the lab’s minimal system prompt, and thinking disabled.
- Prompt: `Reply with exactly: QWEN_LAB_1_OK`.
- Observation: Qwen returned exactly `QWEN_LAB_1_OK` in one model turn, with no tool calls and no reasoning tokens reported.
- Reported usage: 67 input tokens and 9 output tokens.
- Scope: this proves endpoint connectivity and instruction following for one trivial prompt. It does not establish general reliability or isolate Qwen from all vLLM sampling/template effects.

Future entries should state the exact harness configuration, prompt, observation, and a trace path or sanitized excerpt. Keep model behavior separate from Pi serialization and vLLM behavior.

## 2026-09-09 — Lab 2 tool selection

- With exactly `structured_echo` and `workspace_inventory` exposed, Qwen selected the explicitly requested tool in both controlled cases and produced schema-valid arguments on the first attempt.
- After each tool result, Qwen produced a grounded final answer in the second model turn. For the inventory case it accurately repeated the observed counts: 9 files and 2 directories at the time of the run.
- This shows correct behavior for strong, explicit tool instructions. It does not yet measure ambiguous selection, malformed arguments, or recovery from tool failure.

## 2026-09-09 — Lab 5 controlled context injection

- With the same model, system prompt, user prompt, no tools, and no session, Qwen returned `NO_MARKER` in the baseline.
- Adding one temporary extension message changed the response to `INJECTION_SEEN`.
- The causal input difference is visible in both Pi’s context event and final provider payload. This is a clean demonstration that harness context can alter model behavior; it is not evidence that prompt instructions enforce policy.

## 2026-09-09 — Same model, different harness smoke benchmark

- All configurations used `home-vllm/qwen3.8-27b-fp8` with thinking off across the same three workspace-evidence tasks.
- Minimal Pi declined to claim answers it could not inspect: 0/3 completion, zero tools, 3,197 ms total latency, 110 output tokens, and 192 input-context tokens.
- Coding, planner/executor, actor/verifier, and multi-agent configurations each completed 3/3 with observed read evidence. Their total measured latencies were 6,437 ms, 12,504 ms, 8,477 ms, and 8,690 ms respectively in this run.
- The verification configuration first omitted the fixture's trailing newline, received a content-mismatch failure, retried with the exact content, and passed. It completed with two tool calls, one failed call, and one observed recovery.
- No successful run made an unsupported success claim under the experiment's operational definition: a correct answer required a successful read, verified receipt, or child-read observation.
- This is a three-task deterministic smoke suite, not a performance ranking. It demonstrates that control flow and evidence requirements produce measurable differences while the model stays fixed.

## 2026-09-09 — Python control, concurrency, and direct loop

- Qwen returned each exact controller token through Pi RPC in Labs 16–20, including three blackboard roles and two simultaneously active boundary-probe workers.
- The process-concurrency probe produced the expected independent results and distinct Pi session IDs. It tested functional isolation, not throughput or quality under sustained load.
- In the direct Lab 21 API loop, Qwen emitted a schema-valid `read_file` call on the first turn and returned `TINY_OK` after the tool result on the second turn.
- The direct result matches Pi's basic two-turn tool behavior from Lab 2, while the implementation comparison shows that the matching happy path says little about sessions, lifecycle, compatibility, cancellation, policy, or recovery.
