# Primitive taxonomy

A primitive is a small mechanism with a clear contract that can be composed into larger behavior. A product label such as “planner” is not automatically a primitive. The working test is: can several distinct architectures reuse this mechanism without knowing the feature name?

## Ownership vocabulary

| Layer | Owns | Does not by itself own |
|---|---|---|
| Qwen/model | Token generation, reasoning choices, tool-call proposals, natural-language claims | Tool execution, durable state, permissions, truth of completion claims |
| Pi/runtime | Agent loop, provider adaptation, messages, sessions, tool dispatch, lifecycle, context construction, extension loading, TUI | Application-specific workflow durability or organizational policy |
| Extension | Behavior composed through Pi hooks, tools, commands, UI, and extension state | A second agent runtime |
| External orchestration | Worker selection, durable tasks, queues, schedules, shared databases, recovery across processes | The internal Pi model/tool loop unless deliberately replacing it |

## Initial Pi primitive catalog

This is a living catalog. API details are pinned to the installed `@earendil-works/pi-coding-agent` 0.85.1 and must be rechecked after upgrades.

| Primitive | Minimal mental model | Inputs → outputs | State owner / lifecycle | Common compositions and failure modes |
|---|---|---|---|---|
| Provider/model adapter | Translate Pi’s model call into a provider protocol | model, messages, tools, settings → streamed assistant events | Pi model runtime; per request | Local vLLM, routing. Compatibility flags can serialize roles or reasoning fields incorrectly. |
| Agent loop | Continue until the model stops requesting tools | context + tools → assistant messages and tool cycles | Pi agent core; one run | Coding agent, verifier. Can loop, retry, or stop without proving task success. |
| Message | Typed unit of conversation | user/assistant/tool/custom content → context candidate | Pi session/runtime | Transcript, injected notes. Visible message is not necessarily final provider serialization. |
| Context construction | Select and transform messages for one call | session messages + hook results → request messages | Pi per model turn | Pruning, injection, compaction. Can duplicate, stale, or omit information. |
| System-prompt construction | Assemble runtime instructions and resource context | tools, cwd, context files, skills, additions → system text | Pi per turn | Modes and policies. Ordering can create conflicts; provider serialization may change roles. |
| Tool definition | Describe callable capability and validate its input | name + description + runtime schema + executor → result | Pi registry; session runtime | Filesystem, search, domain actions. A schema does not make a tool safe. |
| Tool execution | Run a validated call and return structured content | tool call → result/error | Pi agent loop; per call | Acting and evidence gathering. Side effects may be irreversible; outputs may be huge. |
| Lifecycle event/hook | Observe or alter a named transition | event + context → optional mutation/block | Pi extension runner; ordered handlers | Tracing, policy, context mutation. Handler order and accidental mutation matter. |
| Extension | Load a module that registers hooks, tools, commands, or UI | factory(`ExtensionAPI`) → registrations | Pi resource loader; process/session reload | Policies, instrumentation, derived modes. Runs with host permissions and can overreach. |
| Command | Human-triggered control outside model tool choice | slash command + args → extension action | Pi interactive/RPC surface | Toggle mode, inspect state. Non-interactive availability varies. |
| Session transcript | Append-only record and branchable conversation | entries → reconstructed conversation | Pi `SessionManager`; persistent unless ephemeral | Resume, fork, audit. Transcript is not identical to current model context. |
| Extension state | Data owned by one extension | events/commands → memory or appended custom entries | Extension memory or Pi session entries | Counters, modes. In-memory values disappear; serialized formats need versioning. |
| Skill | Discoverable instruction module loaded into context when invoked | metadata + instructions → prompt content | Pi resource loader/context | Procedures and domain guidance. Consumes context and cannot enforce policy. |
| Compaction | Replace older conversational detail with a summary | branch entries + budget → summary + kept entries | Pi session/context boundary | Long-running tasks. Summaries can lose requirements or evidence. |
| Output mode | Adapt the same runtime events to a consumer | agent events → TUI, text, JSONL, or RPC | Pi mode layer; process lifetime | Human use, capture, Python control. Presentation should not be confused with reasoning. |
| Receipt | Structured observation supporting a claim | environment event → evidence record | Harness extension/external store | Verification and evaluation. A receipt proves only what its observation actually covers. |
| Worker process | One configured Pi instance | task + harness config → result + events | External orchestrator and child Pi | Sub-agents, pipelines. Isolation, timeout, transport, and cost need explicit handling. |
| RPC controller | Drive a headless Pi worker over strict JSONL | commands → responses + asynchronous events | External process; one or more worker lifetimes | Python controllers and IDEs. Must frame LF records, handle asynchronous settling, timeouts, and cleanup. |
| Durable task record | Persist workflow truth independently of an agent conversation | task, status, attempts, blocker, result → schedulable state | External database; spans processes and sessions | Autonomous runners. Needs migrations, idempotency, and explicit terminal states. |
| Lease | Atomically grant temporary ownership of ready work | task + worker + expiry → exclusive claim or none | External transactional scheduler | Queues and crash recovery. Expiry can duplicate side effects unless execution is idempotent. |
| Blackboard | Shared durable facts and work visible to independent workers | observations, claims, tasks, artifacts → activations/conflicts | External transactional store | Loosely coupled specialists. Stale facts, contention, cycles, and context growth need policy. |
| Activation rule | Decide when shared-state work becomes eligible | durable state change → ready task/worker | External scheduler or blackboard | Dependency graphs and event-driven agents. Hidden or cyclic rules can stall the system. |
| Orchestration topology | Define worker, state, and communication ownership | task graph + worker configs → dispatch/result graph | External controller | Pipelines, map-reduce, routers, critics. Role prompts alone do not create a different topology. |

## Composition test

When naming a new feature, rewrite it as existing primitives first. Add a primitive only if it has an independent contract, lifecycle, and reuse across multiple features. Prompt wording alone is model context; it is not enforcement, state, or orchestration.
