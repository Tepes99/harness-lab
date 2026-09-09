# Lab 10 — Skills and reusable instructions

## Objective
Compare system prompt, skill, extension context, and tool implementations of the same classification.
## Pi primitive
Skills are discoverable instruction modules whose metadata enters the system prompt and whose body loads on demand or explicit invocation.
## Mental model
System prompt and skill guide Qwen; an extension controls context/lifecycle; a tool executes deterministic code.
## TypeScript needed
No new syntax: the contrast is architectural rather than linguistic.
## Implementation
Two reusable skills live under `skills/`. `npm run lab:10` classifies the same missing-evidence scenario through four mechanisms.
## Inspect
Compare event streams: where is the rule, does a tool call occur, and can the mechanism enforce anything? Inspect Pi’s `skills.js` formatter and resource loader.
## Experiment
Make the wording ambiguous. Skills and prompts may vary; the deterministic tool remains stable for its narrow boolean input.
## Break it
Remove skill `description`; Pi should warn or skip it. Invoke a nonexistent skill and inspect expansion failure.
## Explain
When is a skill better than a prompt? Why is a tool inappropriate for broad prose guidance? Why can a skill not enforce policy?
## Reusable artifact
`evidence-summary` and `failure-boundary` skills.
## Completion criteria
All four variants run; their context/control-flow differences can be identified even when labels match.
