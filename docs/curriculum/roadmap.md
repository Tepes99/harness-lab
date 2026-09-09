# Curriculum

The curriculum grows by experiment. Each lab must leave a runnable artifact, a trace or other evidence, and an explanation of which layer owns each observed behavior. A phase may contain several small labs when one experiment would mix too many variables.

| Phase | Question | Build or experiment | Evidence | Exit condition |
|---|---|---|---|---|
| 0. Orientation | How is installed Pi connected to Qwen, and which TypeScript is immediately useful? | Environment inventory and incremental TypeScript guide | Version, provider/model inventory, type check | Pi and Qwen respond through the configured vLLM provider |
| 1. Minimal Pi | What is the smallest useful Pi interaction? | Tool-free, ephemeral run plus request recorder | JSON event stream and provider-payload trace | Explain one complete turn and layer ownership |
| 2. Custom tool | How does a model request become executed code? | Trivial tool, then one useful inspector | Valid, malformed, and failing calls | Trace validation, execution, result, continuation |
| 3. Lifecycle | Which hooks observe, mutate, or block? | Human-readable lifecycle tracer | Ordered event traces | Classify important hooks by power and timing |
| 4. State | Where can information live? | Stateful extension | Restart and session-switch observations | Distinguish context, transcript, extension, and durable state |
| 5. Context | What does the model see and why? | Context inspector and controlled injection | Source-attributed context snapshots | Explain inclusion, duplication, conflict, and size |
| 6. Policy | How is capability separated from permission? | Same tools under unrestricted and read-only policies | Allowed and denied traces | Show that tool availability and authorization differ |
| 7. Derived plan mode | Can planning be composed from primitives? | Command, state, context change, policy, optional UI | Mode transition trace | Decompose plan mode without a new runtime |
| 8. Verification | How can completion claims be checked? | Receipt schema and verifier | Supported and unsupported claims | Environment evidence can contradict model prose |
| 9. Observability | What must be measured before autonomy? | Structured event sink and formatter | Latency, usage, tools, errors, state/context changes | Traces support debugging and evaluation |
| 10. Skills | When should behavior be an instruction module? | Equivalent task via prompt, skill, extension, and tool | Comparative traces | Explain when each mechanism fits |
| 11. Compaction | What survives context pressure? | Compaction torture test | Before/after context and task outcomes | Identify loss modes before changing compaction |
| 12. Memory | Which kinds of memory belong inside or outside Pi? | Extension plus SQLite; external Python service plus tool | Persistence and retrieval comparison | Match memory type to owner and lifecycle |
| 13. Sub-agents | Is a child Pi process a sufficient worker abstraction? | Parent/child, then specialist workers | Isolated sessions, failures, timeouts, usage | State limits and recursion behavior are understood |
| 14. Harness catalog | Which compositions are meaningfully different? | Minimal, coding, analyst, researcher, planner/executor, actor/verifier, reviewer, low-context, autonomous | Architecture cards and runnable configs | Differences are structural, not role-name changes |
| 15. Same model, different harness | How much behavior comes from the harness? | Benchmark Qwen under multiple harnesses | Completion, calls, claims, latency, tokens, interventions | Results isolate important harness variables |
| 16. Python controller | What belongs outside the worker? | CLI or FastAPI controller using supported Pi integration | Process/RPC event trace | Python controls Pi without duplicating its loop |
| 17. Durable runner | How does a task survive process failure? | Task records, scheduler, queue, checkpoints, recovery | Crash/restart experiment | Durable workflow and Pi loop remain distinct |
| 18. Blackboard | When does shared state beat direct delegation? | Small external blackboard and Pi workers | Claims, conflicts, ownership, activation | Compare shared-state and parent/child topologies |
| 19. Orchestration patterns | Which topology fits which workload? | Supervisor, pipeline, map-reduce, critic, router, queue | Cost, latency, state, failure-mode cards | Architecture differences are empirically grounded |
| 20. Pi boundaries | Where does Pi help, stay neutral, or resist? | Stress unusual designs | Boundary classification A-D | Each limitation has an evidence-backed placement decision |
| 21. Optional tiny harness | What work does Pi save? | Minimal Python model/tool loop | Side-by-side capability inventory | Build only after substantial Pi experience |

## Lab contract

Every lab includes: objective, Pi primitive, mental model, TypeScript needed, implementation, inspection targets, experiment, deliberate breakage, explanation questions, reusable artifact, and completion criteria. Each experiment fixes the model and changes as few harness variables as possible.

## Experimental discipline

Before changing prompts or code, state the variable being changed and the expected observation. Preserve raw traces outside git in `.lab-output/`; promote only small, sanitized samples or findings. Separate these labels in notes:

- **MODEL BEHAVIOR:** a choice or generated claim made by Qwen.
- **HARNESS BEHAVIOR:** control flow implemented by Pi or an extension.
- **POLICY:** an allow, deny, or approval decision.
- **STATE:** information retained outside the current request.
- **CONTEXT:** information included in the current model request.
- **ORCHESTRATION:** the rule selecting the next worker or process.

