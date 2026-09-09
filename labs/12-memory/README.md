# Lab 12 — Two memory placements

## Objective
Treat memory as owned storage and retrieval mechanisms, not a single feature.
## Pi primitive
Tools bridge model intent to either extension-local storage or an external service.
## Mental model
Approach A embeds SQLite in the Pi extension process. Approach B keeps SQLite behind a Python HTTP service and gives Pi only a client tool.
## TypeScript needed
Node’s SQLite API is synchronous and process-local; `fetch` plus `AbortSignal` crosses a service boundary asynchronously.
## Implementation
`npm run lab:12` writes different values through both architectures and verifies both databases directly.
## Inspect
Compare ownership, connection lifetime, concurrency, deployment, failure surface, and whether data depends on a Pi session.
## Experiment
Restart Pi and retrieve both keys. Stop the Python service and compare failure recovery with the embedded database.
## Break it
Send missing values and unavailable-service requests. Decide which errors belong in tool results and which need orchestration retries.
## Explain
When must memory live outside Pi? Which store supports multiple workers more cleanly? How does this differ from transcript and context?
## Reusable artifact
Two minimal reference architectures; neither is yet a general memory framework.
## Completion criteria
Both approaches persist values, Qwen invokes each tool, and placement tradeoffs are explicit.
