# Pi findings

## 2026-09-09 — Initial environment inventory

- Global executable: Pi 0.85.1 from `@earendil-works/pi-coding-agent`.
- The selected custom provider is `home-vllm`, using `openai-completions` against an OpenAI-compatible `/v1` endpoint.
- The selected model is `qwen3.8-27b-fp8`, configured with a 131,072-token context window and 16,384 maximum output tokens.
- Compatibility disables the developer role and reasoning-effort field, and enables Pi’s `qwen-chat-template` handling.
- Pi exposes `before_provider_request` after provider serialization. This lets an extension capture the request payload without replacing the provider or agent loop.
- Even a custom system prompt receives `Current working directory: ...` from Pi’s system-prompt builder.
- Non-interactive project extensions require project trust, but an extension explicitly supplied with `-e` loads even when extension discovery is disabled. Lab 1 uses that route.
- The first minimal run made exactly one provider request, exposed no `tools` field, and had no session file. Its payload used `stream: true`, requested usage reporting, set `store: false`, and serialized `chat_template_kwargs.enable_thinking: false` from `--thinking off`.
- The lifecycle trace ordered the relevant events as `session_start → before_agent_start → agent_start → turn_start → context → before_provider_request → after_provider_response → turn_end → agent_end → agent_settled`. User and assistant `message_end` events occurred around the provider call as expected.

## 2026-09-09 — Lab 2 custom tools

- Pi serialized both enabled custom-tool schemas into the first provider request.
- A successful tool call produced an assistant message with `stopReason: "toolUse"`, `tool_execution_start`, `tool_execution_end`, a `toolResult` message, and then a second model turn.
- Tool `content` and `details` both appeared in Pi’s event stream. The textual content is the part meant to continue into model context; details remain structured harness/session metadata.
- The tool executor returning successfully resulted in `isError: false`. Pi’s documented error contract requires the executor to throw for `isError: true`.

## 2026-09-09 — Lab 3 lifecycle

- One user request containing one tool call produced one agent run, two model turns, and 28 summarized lifecycle events including session startup and shutdown.
- The first `context` event contained only the user message. The second contained user, assistant tool-call, and tool-result messages.
- Tool ordering was `tool_execution_start → tool_call → tool_result → tool_execution_end → toolResult message_end`. This separates Pi’s preflight interception from executor completion and message finalization.
- `agent_end` was followed by `agent_settled`, then `session_shutdown`. Status integrations should use `agent_settled` when they care that automatic continuations are exhausted.

## 2026-09-09 — Lab 4 state restoration

- Two separate Pi processes used the same explicit session. Their random extension instance IDs differed, proving module-local state restarted.
- The first process restored the default count zero and persisted count seven. The second process restored count seven from the active branch before executing its read call.
- The session contained both versioned tool-result details and namespaced custom entries. Neither the custom-entry namespace nor ephemeral instance IDs appeared in captured provider payloads.
- `getBranch()` included Pi metadata entries in addition to conversational messages, reinforcing that session storage and model context are different projections of the same append-only history.

## 2026-09-09 — Lab 5 context pipeline

- Baseline and injected runs had identical 177-character system prompts, including Pi’s appended cwd.
- The baseline `context` event contained one user message. The injected run contained that user message plus a `custom` message labeled `lab-05-temporary-context`.
- The OpenAI-compatible provider adapter serialized the custom message as an additional `user` role. Extension-only `details` did not appear in that provider message.
- Provider-reported input usage increased from 78 to 95 tokens after adding the short message. Character-based estimates remain useful for comparison but are not tokenizer-exact counts.

## 2026-09-09 — Labs 6–10 composition primitives

- A tool can remain registered while `tool_call` policy denies execution. This keeps capability discovery separate from authorization and produces an explicit failed tool result.
- Plan mode required no Pi fork: a startup flag, extension state, temporary context, and tool policy produced a non-mutating planning phase.
- A `submit_completion` tool turned a prose claim into an observable state transition. File existence and exact-content checks produced structured pass/fail receipts and could terminate the loop after success.
- JSONL telemetry derived model-call latency, usage, tool outcomes, and run boundaries from lifecycle hooks without replacing the agent loop.
- Equivalent evidence rules could be expressed as a system prompt, skill, extension context, or deterministic tool. Only the tool mechanically classified the supplied evidence; instructions still depended on model compliance.

## 2026-09-09 — Labs 11–15 context, state, and orchestration

- Pi's compaction cut point must leave complete older turns to summarize. One oversized first turn produced “nothing to compact”; moving the oversized content to the latest turn yielded four older messages, both compaction hooks, and a persisted `CompactionEntry`.
- Project compaction settings were visible in `session_before_compact`: `reserveTokens: 1024` and `keepRecentTokens: 100`. The generated summary retained the requested codeword and unresolved requirement in this controlled run.
- Memory worked both as extension-owned SQLite in the Pi process and as SQLite behind a small Python HTTP service. The former is simpler; the latter gives an external orchestrator independent ownership and access.
- A custom tool can spawn Pi in JSON print mode as a bounded child worker. Disabling child extensions/tools and enforcing one delegation depth prevents recursive delegation in the working example.
- The catalog's architectures are configurations and process topologies around Pi. Planner/executor and actor/verifier require a controller-managed handoff even though every worker remains an ordinary Pi process.
- JSON event streams were sufficient to reduce six harness runs into completion, tool, error, evidence, latency, and token metrics. Tool-triggered termination means a verified tool result can be the terminal successful outcome without a later assistant text message.

Do not record API keys or authorization headers here.
