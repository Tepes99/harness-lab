# Pi boundaries

These classifications describe Pi 0.85.1 under the lab's local Qwen/vLLM setup. Recheck them after upgrades. Requiring an external component is a placement decision, not evidence that Pi should be discarded.

| Area | Observed friction or boundary | Evidence | Class | Placement decision |
|---|---|---|---|---|
| Session model | A session is an excellent append-only history for one agent branch, but it is not a leased multi-worker task record. | Labs 4, 11, and 17 | **B** | Keep agent conversation in Pi; keep task ownership/status in an external database. |
| Context lifecycle | Temporary pruning and injection fit the `context` hook; persisted transcripts and provider payloads remain separate projections. | Labs 5 and 11 | **A** | Implement per-worker context policy as an extension and retain source attribution. |
| Concurrency | One Pi process owns one active agent runtime. Concurrent work is clean when controllers start isolated processes. | Lab 20 starts two RPC workers concurrently with distinct session IDs. | **B** | Schedule concurrency outside Pi. |
| Extension API | Tools, policy, context, verification, and telemetry compose cleanly through public hooks. | Labs 2, 6–10 | **A** | Use extensions for behavior within one Pi worker. |
| Extension API: runtime replacement | Changing low-level request scheduling is beyond the composition hooks. | Pi lifecycle/source map and Lab 16 process boundary | **C** | Wrap the provider/runtime component only when its internal contract must change. |
| Orchestration | Pi can spawn a child through a tool, but durable fan-out, leases, and topology state are application workflow. | Labs 13 and 17–19 | **B** | Let a Python controller select and connect Pi workers. |
| Model routing | A controller can choose a model per worker. | Fixed-model workers in Labs 15–20; Pi's model is process/session state. | **B** | Route between workers externally. |
| Model routing: within worker | Transparent per-call routing inside one running agent changes the provider selection contract. | Pi model state and RPC `set_model` operate at explicit session command boundaries. | **C** | Wrap the provider/router only if per-call routing is a defining requirement. |
| Durability | Sessions persist messages, while retries, pause/resume, blockers, and external events need independent schemas and transactions. | Lab 17 crash-recovery trace | **B** | Use a workflow store and reference Pi session/result identifiers. |
| Observability | Extension hooks expose rich events within one worker. | Labs 9 and 16 | **A** | Emit correlated worker events from an extension. |
| Observability: aggregation | Cross-worker traces need shared run/task correlation. | Labs 17–20 | **B** | Aggregate worker streams in the external controller or telemetry store. |
| External state | Tools can access services and databases, but shared-state synchronization should not be hidden in model context. | Labs 12 and 18 | **B** | Own shared memory/blackboards externally and expose narrow tools or worker adapters. |
| Streaming | RPC preserves asynchronous Pi events and works well headlessly, but consumers must implement strict LF JSON framing and asynchronous command responses. | Labs 11, 16, and 20 record streamed `message_update` events. | **A** | Use the supported RPC protocol and a framing-aware client. |
| Parallelism | Tool calls inside one turn follow Pi's loop semantics; independent task parallelism requires multiple workers and resource control. | Lab 20 concurrent-process probe | **B** | Bound parallelism in the external scheduler. |
| Subprocess control | A tool can spawn Pi, but cancellation, timeouts, depth, stderr, exit codes, and orphan cleanup become harness responsibilities. | Labs 13, 15, and 16 | **B** | Centralize lifecycle controls in the Python worker adapter. |

## Classification key

- **A — Clean extension:** Pi exposes the needed lifecycle or capability boundary.
- **B — Better outside Pi:** the concern spans workers, time, or durable shared state.
- **C — Wrap or replace a component:** the desired behavior changes an internal provider/runtime contract rather than composing public hooks.
- **D — Fundamental incompatibility:** the architecture cannot preserve its defining invariant while using Pi as a worker.

No Class D incompatibility appeared in Labs 1–20. Blackboard, durable queues, heterogeneous topologies, and concurrent workers all retained Pi by placing coordination outside the worker. The strongest Class C candidate is transparent routing or scheduling inside Pi's provider/agent-loop boundary; an external router avoids that replacement for the architectures tested here.

## Probe interpretation

The concurrency probe starts two complete RPC processes at once, retains their event streams, verifies distinct sessions, and writes both results into one external SQLite database. It demonstrates that Pi is neutral and composable under process-level parallelism. It does not prove that sharing one session file across writers is safe, nor does it establish throughput at scale.
