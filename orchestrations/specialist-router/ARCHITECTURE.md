# Specialist router
## STRUCTURE
A routing rule chooses one differently configured Pi specialist per task.
## STATE TOPOLOGY
The controller records the routing decision and selected worker result.
## COMMUNICATION TOPOLOGY
One-to-one dispatch after classification; unselected workers receive nothing.
## ADVANTAGES
Small specialist contexts and task-specific tools or policy.
## FAILURE MODES
Misrouting, ambiguous tasks, missing fallback, and classification overhead.
## TOKEN COST
Deterministic routing costs no model tokens; model routing adds one call.
## LATENCY
Routing time plus one specialist run.
## BEST USE CASE
Mixed task streams with recognizable capability boundaries.
