# Planner-executor
## STRUCTURE
A read-only planner emits a plan consumed by a separately configured executor.
## STATE TOPOLOGY
A versioned plan and acceptance decision form the phase boundary.
## COMMUNICATION TOPOLOGY
One-way plan handoff, followed by execution receipts to the controller.
## ADVANTAGES
Planning cannot silently mutate, and execution can be audited against intent.
## FAILURE MODES
Stale plans, lossy handoffs, infeasible steps, and executors that drift.
## TOKEN COST
Two contexts plus the plan duplicated into execution.
## LATENCY
At least two sequential model phases.
## BEST USE CASE
Changes where an inspectable plan is valuable before mutation.
