# Pi lifecycle

Pi’s lifecycle is nested. A session can contain many agent runs; an agent run can contain many model turns; a turn can contain zero or more tool calls. “Turn” here means one model response plus the tools it requests, not an entire user request.

```text
session
└── agent run
    ├── turn 0: model requests tool
    │   └── tool preflight → execution → result
    └── turn 1: model answers from tool result
```

## Hook powers

| Hook or family | Timing | Power | Typical use | Main misuse |
|---|---|---|---|---|
| `session_start`, `session_shutdown` | Runtime bind/teardown | Observe; initialize or flush extension resources | Restore state, open/close sinks | Starting resources in the extension factory and leaking them across reloads |
| `before_agent_start` | After input expansion, before agent loop | Inject a message; replace/chains system prompt | Modes and temporary instructions | Hidden prompt growth or conflicting late handlers |
| `agent_start`, `agent_end`, `agent_settled` | Around low-level run / after all automatic continuation | Observe | Status and accounting | Treating `agent_end` as final even when retry or compaction will continue |
| `turn_start`, `turn_end` | Around one model response and its tool batch | Observe | Per-call latency and result counts | Calling one user request “one turn” when tools create more turns |
| `message_start`, `message_end` | Around finalized user, assistant, and tool messages | Observe; `message_end` can replace same-role message | Audit or normalization | Rewriting history invisibly |
| `context` | Immediately before each model call | Replace message list non-destructively | Pruning, injection, inspection | Dropping requirements or tool-result pairing |
| `before_provider_headers` | After headers are built | Mutate headers | Tracing and gateway attribution | Logging or leaking authorization headers |
| `before_provider_request` | After provider serialization | Observe or replace final payload | Serialization debugging | Breaking provider schema, bypassing higher-level invariants |
| `after_provider_response` | Response received, before stream consumption | Observe | Status and latency correlation | Assuming HTTP 200 means valid or complete model output |
| `tool_execution_start/update/end` | Around finalized execution | Observe | Progress and metrics | Treating start as proof of completion |
| `tool_call` | After execution-start event, before executor | Mutate input or block | Policy and compatibility | Mutated input is not revalidated; unsafe changes can bypass the schema |
| `tool_result` | After executor, before final result events | Replace content/details/error/usage | Redaction and normalization | Turning an error into apparent success or injecting oversized context |
| compaction and tree hooks | Before/after context-history transformations | Cancel or replace summaries/navigation | Custom retention | Losing evidence or corrupting branch semantics |

## Ordering observations

The reusable [`lifecycle-trace.ts`](../../extensions/observability/lifecycle-trace.ts) assigns its own monotonic sequence number because wall-clock timestamps can be equal at millisecond resolution. It deliberately summarizes payloads rather than duplicating the full context recorder.

In the Lab 3 tool run, expect two `turn_start`/`context`/provider-request cycles. Tool preflight and execution occur inside the first turn. `agent_settled` is the reliable “Pi will not automatically continue” signal.

Hooks run in extension load order. Mutation hooks therefore form middleware chains: a later hook sees earlier changes. Observational extensions should return `undefined` and avoid mutating event objects.

