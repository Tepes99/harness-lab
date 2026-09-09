# Shared task queue
## STRUCTURE
Producers enqueue durable tasks; interchangeable Pi workers lease ready items.
## STATE TOPOLOGY
The queue owns status, attempts, leases, checkpoints, and terminal results.
## COMMUNICATION TOPOLOGY
Workers pull tasks and publish results through the queue rather than each other.
## ADVANTAGES
Horizontal workers, backpressure, retries, and crash recovery.
## FAILURE MODES
Poison tasks, expired leases, duplicate effects, starvation, and weak idempotency.
## TOKEN COST
One configured worker context per attempt.
## LATENCY
Queue wait plus worker runtime; throughput can scale with consumers.
## BEST USE CASE
Independent durable jobs with explicit retry and ownership semantics.
