# Lab 3 — Lifecycle and event powers

## Objective

See the order and nesting of Pi events, then distinguish notification hooks from hooks that can mutate context, block tools, or persist state.

## Pi primitive

Pi’s extension event bus exposes lifecycle transitions around sessions, agent runs, model turns, messages, provider requests, and tools. Hooks share names but have different powers; read the return contract before using one as policy.

## Mental model

One user request starts one agent run. A tool request ends the first model turn, executes inside that turn, and triggers a second model turn. The run ends only after Qwen stops requesting tools. `agent_settled` comes after retry, compaction, and queued-continuation decisions.

## TypeScript needed

This lab uses callbacks and discriminated unions from earlier labs. In `message_end`, checking `message.role` narrows the union so TypeScript permits assistant-only `stopReason` or tool-result-only `toolName` fields. The recorder’s `Record<string, unknown>` accepts small summaries without pretending they all share one shape.

## Implementation

[`lifecycle-trace.ts`](../../extensions/observability/lifecycle-trace.ts) is the first promoted reusable extension. It records an ordered JSONL trace with summaries and no response headers or full prompt bodies. [`format.sh`](format.sh) renders it for humans.

```bash
npm run check
npm run lab:03
```

## Inspect

Compare the formatted lifecycle with Pi’s JSON event stream in the reported output directory. Count turns and locate the tool preflight inside turn 0. Then read [the lifecycle classification](../../docs/concepts/lifecycle.md).

In installed Pi source, inspect `dist/core/agent-session.js` around `_handleAgentEvent`, `_emitExtensionEvent`, and `_installAgentToolHooks`. In `dist/core/extensions/runner.js`, inspect the emit methods for `context`, `tool_call`, and `tool_result`; compare how their return values are combined.

## Experiment

Run once with `structured_echo`, then repeat with `--no-tools` and a simple answer prompt. The no-tool run should contain one turn and no tool events. The difference comes from control flow, even though the model and runtime stay fixed.

## Break it

Temporarily add two `tool_call` handlers: the first changes a valid `repeat` value to `99`; the second logs it. Pi documents that later handlers see the mutation and that it is not revalidated. Do this only with the side-effect-free echo tool. Explain why argument mutation is dangerous for filesystem or shell tools.

Next make an observational handler throw. Confirm Pi reports an extension error and determine whether the underlying run continues. Remove the change afterward.

## Explain

1. Why can one user request contain two turns?
2. Which event is the best final-idle signal?
3. Which hooks are observational, mutating, blocking, or persistent?
4. What runs before and after context construction?
5. Why does extension load order matter?
6. Which hook could silently invalidate schema guarantees?

## Reusable artifact

The lifecycle tracer is reusable structured observability. It records bounded summaries; Lab 5 owns full context inspection.

## Completion criteria

- The run produces a numbered, human-readable trace.
- The trace contains two model turns and one successful tool execution.
- Event ordering matches the documented nesting.
- Hook powers and the dangerous mutation points can be explained.
