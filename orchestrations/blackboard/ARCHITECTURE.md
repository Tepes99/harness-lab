# Blackboard
## STRUCTURE
Independent Pi specialists claim and publish through a shared transactional store.
## STATE TOPOLOGY
Tasks, observations, artifacts, ownership, and conflicts are shared durable records.
## COMMUNICATION TOPOLOGY
Workers communicate indirectly by reading and writing the blackboard.
## ADVANTAGES
Loose coupling, durable collaboration, event activation, and replaceable workers.
## FAILURE MODES
Stale observations, conflicting claims, deadlocks, contention, and uncontrolled context growth.
## TOKEN COST
Depends on how much shared state each worker retrieves.
## LATENCY
Activation dependencies and queue contention determine the critical path.
## BEST USE CASE
Long-lived collaboration where no single parent should own all coordination.
