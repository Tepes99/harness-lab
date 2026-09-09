# Lab 7 — Plan mode as a derived feature

## Objective
Build plan mode from existing Pi mechanisms instead of a new subsystem.
## Pi primitive
Flag and command, extension state, custom context, tool interception, and optional UI status.
## Mental model
`Plan Mode = state + command/flag + context injection + mutation policy + status`.
## TypeScript needed
Closures hold ephemeral mode state; a namespaced custom entry persists command changes; callbacks project state into context and policy.
## Implementation
[`plan-mode.ts`](plan-mode.ts) registers `--plan` and `/plan`, restores state, injects a plan instruction, blocks the lab mutation tool, and displays TUI status when available. Run `npm run lab:07`.
## Inspect
Confirm the tool schema is still present, the custom plan message enters context, and no marker exists. Compare with Lab 6 read-only policy.
## Experiment
Run without `--plan`; change only mode state. In TUI, toggle `/plan`, restart the session, and inspect the custom state entry.
## Break it
Remove the policy hook but retain prompt text and force a tool request. This exposes why “do not mutate” is not enforcement.
## Explain
Which terms create plan mode? Which are model guidance versus harness enforcement? Why is the feature derived?
## Reusable artifact
The decomposition is reusable; this small implementation stays in the lab until policy design matures.
## Completion criteria
Plan context is visible, output is a plan, mutation is absent, and the active capability remains inspectable.
