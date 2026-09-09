# Lab 6 — Tool policy

## Objective
Separate executable capability from enforced permission.
## Pi primitive
`tool_call` runs after schema validation and before execution; it can block a call.
## Mental model
The same tool and model run under two policy values. Only the policy decision changes.
## TypeScript needed
The handler returns either `undefined` (allow) or `{ block: true, reason }` (deny), a union inferred from control flow.
## Implementation
[`capability.ts`](capability.ts) writes only an experiment marker. The reusable [policy extension](../../extensions/policies/tool-policy.ts) enforces `unrestricted` or `read-only` from harness configuration. Run `npm run lab:06`.
## Inspect
Compare both provider tool schemas, policy JSONL files, tool-result events, and marker existence. Read `emitToolCall` in Pi’s extension runner.
## Experiment
Change only `HARNESS_TOOL_POLICY`. Then remove the tool entirely and compare “unavailable” with “available but denied.”
## Break it
Rename the tool without updating policy; observe why deny lists need defaults and tests. Restore it afterward.
## Explain
Why can prompt text not enforce permission? When is removing capability preferable to interception? Where does schema validation occur?
## Reusable artifact
The policy hook and audit shape move to `extensions/policies/`; the marker stays a fixture.
## Completion criteria
The unrestricted case writes; read-only does not; both expose the same tool; the audit proves Pi’s decision.
