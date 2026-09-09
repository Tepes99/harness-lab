# Lab 14 — Harness architecture catalog

## Objective
Show that distinct harnesses can be composed around one unchanged Pi runtime.
## Pi primitive
CLI resource selection: tools, extensions, skills, prompts, sessions, and process boundaries.
## Mental model
A harness is a named composition of Pi plus capabilities, policy, context, and control flow.
## TypeScript needed
None. This lab deliberately makes architecture visible as JSON, Markdown, and shell composition.
## Implementation
`harnesses/catalog.json` gives a machine-readable index. Each harness has an `ARCHITECTURE.md`; `harnesses/run.sh` launches the single-process variants and points multi-stage variants to their dedicated experiment runners.
## Inspect
Compare capability lists and process topology without comparing model names; every entry uses the same Qwen endpoint.
## Experiment
Run one prompt through `minimal`, `read-only-analyst`, and `researcher`, then compare their event streams.
## Break it
Give the read-only harness a mutation task and verify that no mutating tool is available.
## Explain
Which behavior belongs to Pi, which belongs to configuration, and which requires an external controller?
## Reusable artifact
Machine-readable catalog, architecture cards, and a small launcher.
## Completion criteria
At least ten compositions are documented and two executable compositions pass a live smoke test.
