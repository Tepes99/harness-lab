# Lab 15 — Same model, different harness

## Objective
Quantify behavioral differences caused by harness composition while holding provider, model, task, and thinking level constant.
## Pi primitive
JSON event mode, tool selection, extensions, child processes, and separate Pi sessions.
## Mental model
The model is one experimental variable among prompt, context, capability, policy, verification, and control flow.
## TypeScript needed
The multi-agent tool parses a child event stream. A Node analyzer reduces Pi events into comparable metrics.
## Implementation
Three evidence tasks run through minimal Pi, coding, verification, planner/executor, actor/verifier, and multi-agent configurations. The runner preserves raw events and writes per-task observations, aggregate `results.json`, and `REPORT.md`.
## Inspect
Compare completion, tool calls and failures, unsupported success claims, latency, output tokens, input-context tokens, human intervention, and recovery after tool failure.
## Experiment
Add tasks to `evals/tasks/`, repeat runs, and aggregate distributions rather than treating one sample as a model ranking.
## Break it
Remove or rename the evidence fixture. Observe which configurations admit uncertainty, fail verification, recover, or make unsupported claims.
## Explain
Which observed differences follow from model behavior and which are mechanically induced by the harness?
## Reusable artifact
Benchmark fixture, six-configuration runner, raw event logs, JSON reducer, and Markdown report.
## Completion criteria
All six configurations run the same Qwen model and emit every required metric from inspectable artifacts.
