# Lab 18 — Blackboard architecture

## Objective
Coordinate independent Pi workers through the smallest useful external blackboard.
## Pi primitive
Disposable RPC workers configured by role.
## Mental model
Workers communicate through shared durable observations and artifacts rather than direct parent/child returns.
## TypeScript needed
None. SQLite transactions implement shared coordination.
## Implementation
The blackboard stores tasks, dependencies, observations, claims, artifacts, conflicts, and activation events. Researcher, coder, and reviewer Pi workers claim ready work in sequence.
## Inspect
Observe atomic ownership, dependency activation, how each worker sees accumulated observations, and the explicit conflict record.
## Experiment
Start two workers for the same role concurrently; only one should win the conditional claim transaction.
## Break it
Create a dependency cycle and observe that no task activates, then add cycle detection outside Pi.
## Explain
When is shared-state activation more suitable than a parent waiting synchronously for a child?
## Reusable artifact
Transactional SQLite blackboard and role worker adapter.
## Completion criteria
Three roles complete through shared state, ownership is recorded, artifacts and observations persist, a conflict is visible, and dependency completion activates the next task.
