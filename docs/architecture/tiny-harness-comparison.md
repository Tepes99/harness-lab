# Tiny Python loop versus Pi

The Lab 21 loop implements only one OpenAI-compatible endpoint, messages, one JSON tool schema, local execution, tool-result continuation, a turn cap, and aggregate token counts. That is enough to expose the irreducible model/tool cycle. The inventory below covers the capabilities encountered in Pi 0.85.1's installed documentation and Labs 1–20.

| Capability | Tiny loop | Pi runtime |
|---|---|---|
| Provider/model catalog | One hard-coded provider and model | Provider registry, model metadata, model cycling, compatibility settings, and many API adapters |
| Authentication | Reads one static configured key | Provider-specific authentication, environment credentials, and bearer/OAuth handling |
| Protocol compatibility | Manually sends one chat-completions payload | Normalizes provider messages, tool schemas, thinking, usage, stop reasons, and streaming differences |
| Streaming | No | Incremental assistant events, tool-call deltas, usage updates, and multiple output modes |
| Agent loop | Four-turn `for` loop | Tool continuation, steering, follow-ups, abort, retry, settling, and automatic compaction integration |
| Messages | Three raw role dictionaries | Typed user, assistant, tool-result, custom, and branch/session entries |
| Tool registry | One function and name check | Built-ins and extension tools, enable/deny lists, labels, rendering details, and lifecycle interception |
| Argument validation | Hand-written checks after `json.loads` | Runtime schemas before executor dispatch plus typed extension executors |
| Tool execution | One synchronous file read | Async execution, progress updates, cancellation, structured details, usage, errors, and policy hooks |
| Filesystem/shell tools | One read operation | Read, search, list, shell, edit, and write implementations with agent-loop integration |
| Lifecycle | One local trace array | Session, agent, turn, message, context, provider, tool, compaction, retry, and shutdown events |
| Extensions | No | Public registration surface for hooks, tools, commands, flags, shortcuts, rendering, and UI |
| Context construction | Entire local message list | System-prompt building, context files, skills, prompt templates, extension transforms, and compaction |
| Sessions | No | Append-only persisted sessions, resume, branch, fork, clone, naming, tree inspection, and export |
| Compaction | No | Token-aware preparation, model summary, retained recent entries, and compaction events |
| Interactive control | No | Terminal UI, commands, keybindings, status/widgets, model selection, and approval interactions |
| Headless integration | A one-shot CLI | Text, JSON event, and strict RPC modes with asynchronous commands and extension UI protocol |
| Resource discovery | No | Project/global extensions, skills, prompts, themes, context files, packages, and trust decisions |
| Observability | Turns and token totals | Structured event stream with timings, tool outcomes, usage/cost, session stats, and extension telemetry |
| Policy/verification | Path boundary only | Tool allowlists, interception hooks, project trust, and composable verification receipts |
| Multimodal input | No | Provider/model-aware image and other supported content handling |
| Error recovery | Raise or stop | Provider retry, tool-error continuation, abort controls, session continuity, and external RPC recovery hooks |

The small loop omits every durable multi-worker concern built in Labs 16–20 as well. Pi also does not claim to own those concerns: queues, leases, workflow retries, shared blackboards, and orchestration graphs remain outside both the tiny loop and an individual Pi worker.

The comparison shows why rebuilding Pi would distract from the repository's goal. The educational loop is short because it supports one provider, one tool, one caller, and one failure policy. Each additional capability introduces contracts for state, cancellation, compatibility, observability, and recovery that Pi already implements and tests.
