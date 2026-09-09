# Autonomous harness

**Composition:** bounded coding Pi workers + durable external task state + completion verifier + telemetry + controlled continuation.

The external controller leases work, persists attempt state, and decides whether to continue. Each Pi worker remains disposable. This catalog entry is a target composition; Labs 16–17 build its controller and recovery loop.
