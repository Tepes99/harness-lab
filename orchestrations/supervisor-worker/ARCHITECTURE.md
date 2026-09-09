# Supervisor-worker
## STRUCTURE
One supervisor decomposes work and invokes several bounded Pi workers.
## STATE TOPOLOGY
The supervisor owns the task tree, assignments, and integrated result.
## COMMUNICATION TOPOLOGY
Hub-and-spoke requests and returns; workers do not communicate directly.
## ADVANTAGES
Central priorities, clear decomposition, and straightforward result assembly.
## FAILURE MODES
Supervisor bottleneck, duplicated assignments, lost child results, and weak decomposition.
## TOKEN COST
Supervisor context plus every worker context; often medium to high.
## LATENCY
Supervisor overhead plus the slowest parallel worker and integration pass.
## BEST USE CASE
Tasks with a clear coordinator and independent bounded subtasks.
