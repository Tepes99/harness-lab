# Lab 11 — Context compaction

## Objective
Observe Pi’s existing compaction preparation, summary, and rebuilt-session checkpoint before customizing it.
## Pi primitive
Manual RPC `compact`, compaction settings, session hooks, and `CompactionEntry`.
## Mental model
Older branch messages become a summary while recent entries remain directly represented.
## TypeScript needed
The observer reads typed preparation fields; the small Node client frames RPC strictly on LF-delimited JSON.
## Implementation
A disposable project lowers `keepRecentTokens`. `npm run lab:11` creates two small fact-bearing turns followed by a deliberately oversized recent turn, requests built-in compaction over RPC, and verifies the persisted entry. Putting the large turn last matters: Pi must find complete older turns before its cut point or there is nothing valid to summarize.
## Inspect
Compare messages-to-summarize, `firstKeptEntryId`, generated summary, session JSONL, and rebuilt context. Inspect Pi’s `core/compaction/compaction.js` and `utils...`.
## Experiment
Check whether `ORBIT-731` and the unresolved receipt requirement survive. Repeat without custom instructions and with a large tool result.
## Break it
Interrupt summary generation and observe `session_compact_failed`; then resume the unmodified session.
## Explain
What is summarized, what remains verbatim, and why is a summary not durable ground truth?
## Reusable artifact
Compaction observer and torture-test workspace.
## Completion criteria
Built-in Pi compaction runs, hooks fire, a compaction entry persists, and retained/lost facts can be compared.
