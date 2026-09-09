# Lab 17 — Persistent autonomous task runner

## Objective
Keep durable workflow behavior outside Pi while using Pi as the reasoning worker.
## Pi primitive
Bounded RPC worker runs from Lab 16.
## Mental model
The Pi agent loop is not a durable workflow engine. SQLite records survive worker and controller processes.
## TypeScript needed
None. Python and SQLite own this layer.
## Implementation
The runner stores tasks, statuses, attempts, leases, checkpoints, blockers, results, and events. It supports pause/resume, external unblock signals, retries, and expired-lease recovery.
## Inspect
Follow one task from pause through a simulated worker crash, lease recovery, second claim, and verified final state.
## Experiment
Run two controller processes against one database and observe `BEGIN IMMEDIATE` serialize claims.
## Break it
Use a one-attempt task, expire its lease, and confirm recovery moves it to terminal failure.
## Explain
Why does a session transcript fail to replace task leasing, scheduling, and external-event state?
## Reusable artifact
SQLite task runner that leases disposable Pi RPC workers.
## Completion criteria
A task survives a simulated crash, retries through Pi, retains checkpoints, supports pause/resume, and reacts to an external event.
