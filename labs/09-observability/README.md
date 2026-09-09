# Lab 9 — Structured observability

## Objective
Measure model, context, and tool behavior before adding autonomy.
## Pi primitive
Lifecycle hooks provide stable points for timestamps, sizes, usage, errors, and selection.
## Mental model
Events are facts at boundaries; metrics are derived views over those facts.
## TypeScript needed
`Map` correlates tool start/end IDs; `performance.now()` measures elapsed time; JSONL keeps events streamable.
## Implementation
[`telemetry.ts`](../../extensions/observability/telemetry.ts) records context/request sizes, provider and full latency, tokens, tool arguments/output size/errors, and settlement. Run `npm run lab:09`.
## Inspect
Correlate tool IDs and compare header latency with full streamed-message latency. Treat arguments/output as potentially sensitive.
## Experiment
Run a no-tool prompt and compare calls, tokens, and latency. Feed traces into `jq` without changing the producer.
## Break it
Cause a tool error and network error; verify the trace distinguishes them and still closes the run where possible.
## Explain
Which metrics are observed versus estimated? Why is observability required before retries or autonomy?
## Reusable artifact
Provider-neutral JSONL telemetry sink.
## Completion criteria
Every model call and tool call is correlated with size, latency, usage, result, and final settlement.
