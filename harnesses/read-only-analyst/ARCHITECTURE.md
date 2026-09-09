# Read-only analyst harness

**Composition:** Pi + Qwen + `read`, `grep`, `find`, and `ls` + read-only policy + analysis prompt.

Use it to inspect a repository without mutation. Capability restriction is the security boundary; the policy hook is defense in depth and an observable rejection point.
