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

Do not record API keys or authorization headers here.
