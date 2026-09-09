# Lab 16 — Pi controlled from Python

## Objective
Place a small Python controller around Pi without reimplementing Pi's agent loop.
## Pi primitive
RPC mode with strict LF-delimited JSON commands, responses, and asynchronous events.
## Mental model
Python owns worker lifetime and workflow state; Pi owns the model/tool loop inside one worker run.
## TypeScript needed
None. This boundary is intentionally language-neutral.
## Implementation
`python/harness_lab/pi_rpc.py` starts Pi, sends `prompt`, observes events through `agent_settled`, requests final text/state, computes usage, and terminates the worker.
## Inspect
Compare the prompt acceptance response, asynchronous agent events, and later `get_last_assistant_text` response.
## Experiment
Reuse the controller with a different Pi tool allowlist and compare the resulting event counts.
## Break it
Set a very short timeout or stop the Pi process and inspect how the controller reports worker failure.
## Explain
Why should the controller schedule work while Pi retains responsibility for tool continuation and model messages?
## Reusable artifact
Synchronous Python RPC controller with event and usage capture.
## Completion criteria
Python starts Pi, sends a task, receives events, tracks state, and obtains the exact Qwen result.
