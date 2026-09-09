# Multi-agent harness

**Composition:** a parent Pi with one `delegate_once` tool + a bounded child Pi process with no delegation tool.

The parent chooses and integrates one delegation; the child receives a narrow task and returns a final result. Timeouts, depth limits, and event capture prevent accidental recursive process trees. Lab 13 contains the working primitive.
