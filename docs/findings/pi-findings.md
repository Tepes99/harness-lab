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

Do not record API keys or authorization headers here.
