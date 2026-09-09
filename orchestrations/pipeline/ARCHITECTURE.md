# Pipeline
## STRUCTURE
Fixed Pi stages transform typed outputs in a predetermined order.
## STATE TOPOLOGY
The controller stores each stage artifact and schema version.
## COMMUNICATION TOPOLOGY
Linear stage-to-stage handoffs without dynamic routing.
## ADVANTAGES
Predictable control flow, local stage contracts, and simple replay.
## FAILURE MODES
Early corruption propagates, schemas drift, and a slow stage blocks all successors.
## TOKEN COST
Sum of every stage context and handoff representation.
## LATENCY
Sum of sequential stage times.
## BEST USE CASE
Stable transformations with clear intermediate contracts.
