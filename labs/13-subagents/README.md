# Lab 13 — Sub-agents as Pi processes

## Objective
Use Pi itself as the child worker abstraction and observe isolation, result transport, cancellation, and recursion limits.
## Pi primitive
A parent tool spawns `pi --mode json --print --no-session`, captures events, and returns the final child message.
## Mental model
`sub-agent = isolated Pi process + task prompt + tool/policy config + event/result transport`.
## TypeScript needed
`spawn` creates a child process; Promise-wrapped close events await completion; `AbortSignal` terminates it; a runtime predicate narrows parsed JSON events.
## Implementation
`npm run lab:13` asks parent Qwen to delegate arithmetic to a tool-free child Qwen and verifies successful transport.
## Inspect
The parent transcript contains only the delegation call/result; child events live in tool details count, not parent context. Inspect Pi’s bundled subagent example for parallel/chain elaborations.
## Experiment
Give child a different system prompt or tool set. Preserve child JSONL to compare transcripts. Then add researcher/coder/reviewer configurations.
## Break it
Kill the child, use an invalid model, and attempt recursive delegation. Confirm error, cancellation, and depth boundaries.
## Explain
What is isolated? Who owns child scheduling and timeout? Why is role prompting alone not a multi-agent architecture?
## Reusable artifact
Minimal single-child pattern; concurrency and durable coordination remain external concerns.
## Completion criteria
A separate Pi process runs, returns through the parent tool, has no shared session, and recursion is capped.
