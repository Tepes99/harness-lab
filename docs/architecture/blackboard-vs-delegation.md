# Blackboard versus direct delegation

| Property | External blackboard | Parent/child delegation |
|---|---|---|
| Coordination owner | Shared transactional store | Parent agent/process |
| Communication | Workers publish and read shared records | Child returns directly to parent |
| Worker lifetime | Independent and replaceable | Usually bounded by parent call |
| Task activation | Queries/events over shared state | Parent explicitly invokes child |
| Concurrent claims | Store enforces atomic ownership | Parent serializes or implements locks |
| Conflicts | First-class shared records | Must be returned and reconciled by parent |
| Best fit | Loosely coupled workers and durable collaboration | Bounded decomposition with a clear supervisor |

Both topologies can use identical Pi workers. The architectural difference is the ownership and communication graph, rather than the role prompt assigned to a model.
