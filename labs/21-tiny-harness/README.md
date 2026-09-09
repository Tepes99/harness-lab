# Lab 21 — Tiny harness from scratch

## Objective
Implement the smallest educational model/tool loop after learning what Pi already provides.
## Pi primitive
Comparison target: Pi's provider adapter, agent loop, messages, validation, tools, events, and resource/session systems.
## Mental model
The tiny loop clarifies the plumbing Pi saves; it is not a replacement runtime.
## TypeScript needed
None. The comparison loop uses Python's standard HTTP and JSON libraries.
## Implementation
Python calls the configured OpenAI-compatible Qwen endpoint, supplies one `read_file` schema, executes validated workspace-bounded calls, appends tool results, and repeats until final text.
## Inspect
Trace the two HTTP turns and compare the roughly one-purpose loop with Pi's capability inventory.
## Experiment
Add streaming, cancellation, sessions, or a second provider one feature at a time and record the new state and failure handling each requires.
## Break it
Request a path outside the workspace or force more than four tool turns and observe the explicit local guard.
## Explain
Which code is the irreducible agent loop, and which production concerns immediately expand beyond it?
## Reusable artifact
Tiny standard-library Python model/tool loop and a detailed Pi comparison.
## Completion criteria
Qwen calls a real tool and finishes in two direct API turns; the comparison inventories Pi's additional capabilities.
