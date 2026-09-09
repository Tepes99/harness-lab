# Lab 1 — The smallest useful Pi interaction

## Objective

Observe one complete Pi-to-Qwen turn and identify which facts and behaviors belong to the model, Pi, the lab extension, and vLLM.

## Pi primitive

This lab isolates the provider/model adapter, system-prompt construction, message/context construction, agent lifecycle, event hooks, streaming, and output mode. Tools and session persistence are disabled.

## Mental model

```text
prompt
  → Pi builds context and provider payload
  → vLLM serves Qwen
  → Qwen generates a response
  → Pi streams and finalizes the response
```

The recorder watches the arrows. It does not change them.

## TypeScript needed

Read the first sections of the [TypeScript survival guide](../../docs/typescript-survival-guide.md): imports, constants, objects, callbacks, union narrowing, `unknown`, JSON, and filesystem error boundaries. The extension factory is comparable to a Python function receiving a framework object; `pi.on(...)` registers callbacks.

## Prerequisites and configuration

The current machine was inspected with these results:

- `pi` 0.85.1 is installed globally as `@earendil-works/pi-coding-agent`.
- `~/.pi/agent/models.json` defines provider `home-vllm` at the existing OpenAI-compatible vLLM `/v1` endpoint.
- It defines model `qwen3.8-27b-fp8` with Qwen-specific compatibility settings.
- `~/.pi/agent/settings.json` selects that provider and model by default.

No credential is copied into this repository. Confirm the environment without printing a secret:

```bash
./scripts/check-pi-environment.sh
```

If the provider is moved later, update the user-level Pi config. A minimal vLLM entry has `baseUrl`, `api: "openai-completions"`, an API key or environment reference, and a model entry. For this Qwen endpoint, preserve the observed compatibility flags: no developer role, no reasoning-effort field, and `thinkingFormat: "qwen-chat-template"`.

## Implementation

`run.sh` supplies every relevant disabling flag explicitly. `--no-extensions` disables discovery, while the explicit `--extension request-recorder.ts` keeps the observational extension. `--system-prompt` replaces Pi’s normal coding prompt; Pi still appends the current working directory, which the trace reveals.

Install type-check dependencies once, then run:

```bash
npm install
npm run check
npm run lab:01
```

Pass a different prompt after the script name:

```bash
./labs/01-minimal-pi/run.sh "What is 17 * 3? Answer with only the number."
```

Raw output goes to `.lab-output/lab-01/`. It is ignored by git because provider payloads can contain sensitive context.

## Inspect

Summarize the newest trace and print its final provider payload:

```bash
./labs/01-minimal-pi/inspect-trace.sh
```

Inspect these records in order:

1. `before_agent_start`: Pi’s system prompt and the structured inputs used to build it.
2. `context`: messages available immediately before provider serialization.
3. `before_provider_request`: the exact provider-specific JSON body Pi is about to send.
4. `message_end`: Qwen’s finalized assistant message, including reported usage.
5. `agent_settled`: Pi has no automatic continuation left.

Then complete the targeted source-reading exercise in [Pi source map](../../docs/pi-internals/source-map.md).

## Experiment

Run the default prompt twice. The expected text is deterministic in intent, but any output wording is Qwen behavior. Confirm from the payload that tools are absent, the model ID is correct, and Pi includes both the explicit system prompt and cwd.

Next change exactly one variable: remove `--system-prompt ...` from a temporary command invocation and compare the provider payload. Do not edit the recorded baseline. The large coding-assistant prompt is Pi harness behavior; any response change is Qwen reacting to changed context.

## Break it

Use a nonexistent model while leaving everything else unchanged:

```bash
./labs/01-minimal-pi/run.sh >/dev/null
pi --provider home-vllm --model does-not-exist --print --no-session --no-tools "hello"
```

Pi should fail model selection before Qwen can generate. Classify this as harness/provider configuration failure, not model behavior. Then stop or rename the endpoint temporarily only if you control it and want to observe a transport failure; restoring external services is outside this repository’s state.

## Explain

You should be able to answer:

1. Which serialized fields came from Pi, and which output came from Qwen?
2. Why are a session transcript, a context-event message list, and a provider payload different artifacts?
3. Why can an instruction ask Qwen to avoid a tool while policy can make the tool unavailable?
4. What does the extension observe, and what could the same hooks change?
5. What does Pi supply beyond calling `/v1/chat/completions` directly?
6. Where would a durable Python scheduler sit relative to this run?

## Reusable artifact

The request recorder is intentionally lab-local until another lab proves a stable observability contract. Its event schema and redaction needs will evolve before promotion to `extensions/observability/`.

## Completion criteria

- Environment check lists `home-vllm/qwen3.8-27b-fp8` without exposing credentials.
- TypeScript checks successfully.
- The run exits successfully and records both Pi events and a request trace.
- The provider payload has the expected model, prompt, messages, and no tools.
- You can explain the six checkpoint questions above using the trace and targeted Pi source.

Stop here. Lab 2 begins only after reviewing this checkpoint.
