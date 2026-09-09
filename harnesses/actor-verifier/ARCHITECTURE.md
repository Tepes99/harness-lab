# Actor-verifier harness

**Composition:** one coding Pi actor + one independent read-only Pi verifier + structured completion receipts.

The actor produces an artifact and claim. The verifier receives the task, artifact path, and evidence, then reports pass or fail from fresh inspection. Separation costs another model call but reduces self-approval.
