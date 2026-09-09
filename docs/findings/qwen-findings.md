# Qwen findings

## 2026-09-09 — Minimal exact-response smoke test

- Harness: Lab 1 with no tools, no persisted session, no discovered resources, the lab’s minimal system prompt, and thinking disabled.
- Prompt: `Reply with exactly: QWEN_LAB_1_OK`.
- Observation: Qwen returned exactly `QWEN_LAB_1_OK` in one model turn, with no tool calls and no reasoning tokens reported.
- Reported usage: 67 input tokens and 9 output tokens.
- Scope: this proves endpoint connectivity and instruction following for one trivial prompt. It does not establish general reliability or isolate Qwen from all vLLM sampling/template effects.

Future entries should state the exact harness configuration, prompt, observation, and a trace path or sanitized excerpt. Keep model behavior separate from Pi serialization and vLLM behavior.
