# Lab 8 — Verification and receipts

## Objective
Separate Qwen’s completion claim from environment evidence.
## Pi primitive
A custom completion tool observes the environment, emits receipts, and throws when evidence contradicts the claim.
## Mental model
`claim + observation + completion policy = supported or unsupported completion`.
## TypeScript needed
Literal unions constrain receipt types; `satisfies` checks an object without changing its inferred shape; thrown errors mark tool results failed.
## Implementation
The reusable [completion verifier](../../extensions/verification/completion-verifier.ts) emits claim, observation, and verdict receipts. `npm run lab:08` runs an existing-file and missing-file claim.
## Inspect
Compare receipts with Qwen’s prose and Pi’s `isError`. A successful exit or confident sentence is not equivalent to the expected artifact existing.
## Experiment
Add exact expected content, then deliberately mismatch it. Extend receipts with command exit evidence without treating exit zero as proof of every postcondition.
## Break it
Ask Qwen to claim success without calling `submit_completion`; the absence of a verdict receipt is itself unsupported completion.
## Explain
What does each receipt prove? Who owns the claim, observation, and verdict? Which claims remain unverifiable?
## Reusable artifact
Versionable receipt vocabulary and verifier tool under `extensions/verification/`.
## Completion criteria
One claim passes, one fails for missing evidence, and the verdict follows observations rather than model prose.
