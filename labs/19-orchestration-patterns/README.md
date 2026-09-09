# Lab 19 — Orchestration patterns

## Objective
Compare process, state, and communication topologies instead of merely renaming model roles.
## Pi primitive
Configured Pi worker processes and their result/event transport.
## Mental model
An orchestration architecture is defined by who owns state, which process invokes which worker, and how results move.
## TypeScript needed
None. A Python prototype renders the external process graphs and runs a live routed worker.
## Implementation
Nine machine-readable graphs and architecture cards cover supervisor-worker, planner-executor, actor-verifier, generator-critic, pipeline, map-reduce, blackboard, shared task queue, and specialist router.
## Inspect
Compare edges and state ownership first, then expected cost and latency. Cross-reference Labs 13, 15, 17, and 18 for live constituent patterns.
## Experiment
Replace deterministic routing with a Pi router and measure whether its extra model call improves specialist selection.
## Break it
Remove a reducer edge or create an unbounded critic loop and identify which external invariant must stop it.
## Explain
Why are two differently prompted workers still the same architecture when their state and communication topology are unchanged?
## Reusable artifact
Orchestration catalog, graph event renderer, architecture cards, and live specialist router.
## Completion criteria
All nine patterns expose the required comparison fields, graphs parse, and a routed Pi specialist completes live.
