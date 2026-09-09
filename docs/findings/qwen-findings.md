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
