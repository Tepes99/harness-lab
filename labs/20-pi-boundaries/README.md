# Lab 20 — Find Pi's boundaries

## Objective
Classify where Pi helps, remains neutral, or should be surrounded by another component.
## Pi primitive
RPC workers, sessions, streaming events, extensions, and process isolation accumulated across earlier labs.
## Mental model
A boundary is an ownership decision backed by evidence, rather than a reason to rebuild Pi.
## TypeScript needed
None. The live stress probe operates at the process boundary.
## Implementation
Two Pi RPC workers run concurrently, stream independently, retain distinct sessions, and publish results into shared external SQLite state. The boundary catalog classifies twelve concerns as A, B, C, or D.
## Inspect
Compare wall time, worker time, stream updates, session IDs, and external result rows. Read each classification beside its cited lab.
## Experiment
Increase worker count until the local model server queues requests; separate Pi process overhead from model-serving capacity.
## Break it
Kill one concurrent worker and verify the controller can retain the other result and reschedule only the missing task.
## Explain
Why is external orchestration often a clean complement to Pi rather than architectural failure?
## Reusable artifact
Boundary probe and `docs/pi-internals/boundaries.md`.
## Completion criteria
Every requested concern is classified, concurrent streaming workers run live, and conclusions state their evidence limits.
