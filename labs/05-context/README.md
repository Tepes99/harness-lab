# Lab 5 — Context inspection and controlled injection

## Objective

Answer what Qwen can see, where each part came from, approximately how large it is, and which stage can still change it.

## Pi primitive

This lab uses structured system-prompt inputs, `before_agent_start`, the `context` event, provider serialization, and reported model usage. It keeps session persistence and tools disabled to isolate one injected message.

## Mental model

Context is a per-call projection and pipeline, not a bag of all known information. Inspecting earlier gives clearer source attribution; inspecting later gives a more exact wire representation. vLLM still applies Qwen’s chat template and tokenization after Pi sends the payload.

## TypeScript needed

Read the survival guide’s context-transformation section. `map` builds per-message summaries. Returning nothing from the inspector leaves context unchanged. The injection handler returns a custom message. Provider payloads stay `unknown` unless runtime checks justify accessing their fields.

## Implementation

[`context-inspector.ts`](../../extensions/observability/context-inspector.ts) records:

- Pi’s assembled system prompt and structured sources.
- The exact message list at every `context` event.
- Source labels and character-based size estimates.
- The final provider-specific payload.
- Provider-reported assistant input usage.

[`inject-context.ts`](inject-context.ts) adds one hidden custom message during `before_agent_start`. The run compares identical prompts and configuration with and without that extension.

```bash
npm run check
npm run lab:05
```

## Inspect

The comparison prints system-prompt size, Pi context roles/sources, provider messages, reported input tokens, and final assistant text. Confirm that the baseline and injected system prompts are identical. The injected run should add one extension-sourced context message and one provider message.

Read installed `dist/core/system-prompt.js`, `dist/core/session-manager.js` around `buildSessionContext`, and `dist/core/extensions/runner.js` around `emitContext` and `emitBeforeProviderRequest`. Identify the last point where provider-neutral messages exist.

## Experiment

Keep a copy of the baseline and change one source per run:

1. Add `--append-system-prompt "APPENDED_MARKER"` and locate it in structured sources, final system prompt, and provider payload.
2. Run from a disposable directory containing `AGENTS.md` while removing `--no-context-files`; locate its path/content in system-prompt sources.
3. Supply a small explicit skill with `--skill path --no-skills` and one read-capable tool; observe that metadata enters the system prompt before full skill content is loaded.
4. Use a persisted session for two prompts; compare transcript entries, context messages, and provider messages on turn two.
5. Load two injectors with duplicate or conflicting markers; record handler order and Qwen’s choice without calling that choice policy enforcement.
6. Re-enable a tool that returns a large result; measure the second provider request and observe what dominates context size.

For every case, write the changed variable and prediction before running it.

## Break it

Add a temporary `context` handler that removes the tool-result message while retaining the assistant tool call. Run only against the side-effect-free echo fixture. Observe the provider or model failure caused by an invalid/incomplete tool conversation, then revert the handler.

Next inject two contradictory instructions. Pi will preserve an order, but Qwen’s resolution is model behavior. This demonstrates why context is unsuitable as an authorization boundary.

## Explain

1. What is currently in Qwen’s context, and which evidence supports the answer?
2. Where did the system prompt, cwd, user message, and injected message originate?
3. Why are the character estimates not exact token counts?
4. How do transcript, Pi context, provider payload, and tokenized Qwen input differ?
5. Which hooks can change each stage?
6. Why can context guide behavior but not enforce tool policy?

## Reusable artifact

The context inspector is promoted under `extensions/observability/`. Exact traces remain ignored and should be sanitized before sharing.

## Completion criteria

- Baseline and injected runs differ by one explicit extension.
- The injected message is visible at Pi-context and provider-payload stages.
- Qwen’s answer changes according to the marker.
- System-prompt sources and size estimates are inspectable.
- The limits of Pi-side inspection at the vLLM boundary can be explained.
