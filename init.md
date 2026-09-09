You are my technical mentor, repository architect, and lab designer.

I want to learn agent harness engineering deeply by using **Pi as the underlying agent runtime** and building my own extensions, harness configurations, orchestration patterns, and experiments on top of Pi's primitives.

Do NOT make the main project a ground-up reimplementation of Pi.

The purpose is to understand Pi well enough that I can:

1. understand the primitives Pi exposes,
2. understand how Pi itself works internally,
3. build custom behaviors from those primitives,
4. create reusable Pi extensions,
5. create many different harness architectures using the same underlying runtime,
6. evaluate how harness design changes the behavior of the same LLM,
7. use Pi as a worker runtime inside larger systems,
8. identify where Pi is genuinely limiting,
9. and only then decide whether a particular primitive should be replaced or implemented externally.

My primary LLM is a locally hosted **Qwen 3.8 27B** served through an OpenAI-compatible vLLM endpoint.
To see and make the connections needed to it, look for the currently installed pi on this macbook m1 and how it connects to the vllm and model

Assume the repository is completely empty.

# My background

I am experienced with:

* Python
* SQL
* data engineering
* Linux
* Docker
* FastAPI
* backend/data-oriented software engineering

TypeScript is new to me.

Teach me only the TypeScript needed to work effectively with Pi extensions and Pi's APIs.

Do NOT turn this into a general TypeScript course.

Use Python comparisons whenever they help.

For example:

```text
Python
async def handler(...):

TypeScript
async function handler(...) { ... }
```

or:

```text
Pydantic model
        ↕
TypeScript interface + runtime schema validation
```

# Core architectural philosophy

Use this model:

```text
                  MY SYSTEM
                     │
            orchestration layer
             often Python
                     │
              Pi instances
                     │
          Pi extensions/config
                     │
              Pi primitives
                     │
                Qwen 3.8
```

Pi should initially own things such as:

* agent loop
* model interaction
* message/session mechanics
* tool execution
* lifecycle events
* context management
* extension loading
* interactive controls
* TUI where useful

My code should initially focus on composing and extending those capabilities.

Later, higher-level concerns may live outside Pi:

* durable scheduling
* task graphs
* blackboards
* shared memory
* multi-agent coordination
* queues
* databases
* external event systems
* web APIs
* persistent autonomous workflows

For those, Python may be more appropriate.

Do not force everything into TypeScript merely because Pi uses TypeScript.

# Central learning question

Keep returning to this question throughout the repository:

> What is the smallest set of Pi primitives from which we can construct many different agent architectures?

I want to learn to look at features such as:

* plan mode
* permissions
* reviewer agents
* sub-agents
* memory
* verification
* autonomous execution
* human approval
* context inspection
* multi-agent systems

and mentally decompose them into lower-level mechanisms.

For example:

```text
Plan mode
=
state
+ command
+ context mutation
+ tool policy
+ optional UI
```

rather than treating "plan mode" as a fundamental primitive.

# Critical distinction

Throughout the project explicitly distinguish:

```text
MODEL BEHAVIOR
what Qwen decides

HARNESS BEHAVIOR
what Pi/runtime does

POLICY
what actions are allowed

STATE
what the system remembers

CONTEXT
what the model can currently see

ORCHESTRATION
what determines which agent/process acts next
```

I want experiments that make these differences visible.

# Repository purpose

This repository should become three things at once:

## 1. Learning lab

Hands-on exercises for understanding Pi and harness engineering.

## 2. Experiment repository

Controlled experiments comparing different agent architectures using the same Qwen model.

## 3. Harness catalog

Reusable configurations/extensions that can later spawn different kinds of agents.

A possible structure is:

```text
/
├── README.md
│
├── docs/
│   ├── curriculum/
│   ├── concepts/
│   ├── pi-internals/
│   ├── architecture/
│   └── findings/
│
├── labs/
│   ├── 01-minimal-pi/
│   ├── 02-custom-tool/
│   ├── 03-events/
│   ├── 04-state/
│   ├── 05-context/
│   └── ...
│
├── extensions/
│   ├── examples/
│   ├── observability/
│   ├── verification/
│   ├── policies/
│   ├── memory/
│   └── orchestration/
│
├── harnesses/
│   ├── minimal/
│   ├── coding/
│   ├── researcher/
│   ├── read-only/
│   ├── planner-executor/
│   ├── actor-verifier/
│   ├── autonomous/
│   ├── multi-agent/
│   └── experimental/
│
├── experiments/
│   ├── context/
│   ├── tools/
│   ├── verification/
│   ├── memory/
│   ├── planning/
│   ├── orchestration/
│   └── model-behavior/
│
├── python/
│   ├── orchestration/
│   ├── services/
│   └── experiments/
│
├── evals/
├── fixtures/
└── scripts/
```

Improve this structure if Pi conventions or practical experience suggest something better.

# Important rule: do not rebuild Pi unnecessarily

Whenever I propose implementing something, first ask architecturally:

> Does Pi already expose a primitive that solves the lower-level problem?

If yes, use it.

For example, do not create:

* our own tool loop
* our own session engine
* our own extension loader
* our own message protocol
* our own terminal UI framework

unless an experiment specifically aims to understand or replace that mechanism.

I want to learn where Pi ends and my architecture begins.

# Phase 0 — Pi orientation + TypeScript survival kit

Start by getting the simplest Pi + Qwen setup working.

Teach me enough TypeScript to understand Pi extension code.

Cover only practical concepts such as:

* Node and package management
* tsconfig at a practical level
* imports / exports
* const / let
* objects
* arrays
* functions
* arrow functions
* async / await
* Promises
* interfaces
* type aliases
* unions
* discriminated unions
* generics only when Pi code requires them
* optional properties
* callbacks
* event handlers
* error handling
* filesystem APIs
* child processes
* AbortController
* JSON
* runtime schemas
* compile-time type versus runtime validation

Do not spend time on frontend TypeScript.

Teach through Pi-related examples instead of generic toy exercises.

Create:

```text
docs/typescript-survival-guide.md
```

It should contain the TypeScript concepts I am actually encountering while working through the labs.

Expand that document incrementally rather than dumping an entire language tutorial initially.

# Phase 1 — Strip Pi down

Goal:

Understand what the smallest useful Pi setup actually does.

Use Qwen 3.8 as the model.

Experiment with Pi with unnecessary extras disabled where possible.

I want to observe:

```text
user prompt
     ↓
Pi runtime
     ↓
Qwen
     ↓
response
```

Investigate and document:

* what system prompt Qwen receives
* what context Pi injects
* what tool definitions exist
* what session data exists
* what Pi stores
* what happens during one turn
* what happens during multiple turns
* what comes from Pi versus what comes from Qwen

Create a document:

```text
docs/pi-internals/minimal-runtime.md
```

Include a sequence diagram.

# Phase 2 — First custom tool

Create a very simple Pi extension that registers a custom tool.

Start with something deliberately trivial.

Examples:

* calculator
* current working directory inspector
* structured JSON echo
* small filesystem inspector

Then create a real useful tool.

Teach:

* Pi tool registration
* input schema
* runtime validation
* tool execution
* tool result
* errors
* what enters the model transcript

Experiment with malformed arguments and failures.

Document:

```text
MODEL REQUESTS TOOL
        ↓
PI VALIDATES
        ↓
TOOL EXECUTES
        ↓
RESULT ENTERS CONTEXT
        ↓
MODEL CONTINUES
```

# Phase 3 — Pi lifecycle and events

Explore the events/hooks Pi exposes.

Do not merely list them.

Build an extension that logs the lifecycle.

I want to see a trace resembling:

```text
agent start
turn start
context built
model call start
model call end
tool call start
tool call end
turn end
agent end
```

Create a human-readable trace.

Then answer:

* Which events are observational?
* Which can alter behavior?
* Which can mutate state?
* Which operate before/after context construction?
* Which are dangerous to misuse?

Create:

```text
docs/concepts/lifecycle.md
```

# Phase 4 — Extension-owned state

Build a stateful extension.

Examples:

* counter of model calls
* tool usage statistics
* session notes
* task status
* current operating mode

Teach:

* ephemeral state
* session state
* persistent state
* extension namespacing
* serialization
* state restoration

Experiment with restarting Pi and changing sessions.

Explicitly distinguish:

```text
model context
≠
extension state
≠
session transcript
≠
filesystem/database state
```

# Phase 5 — Context manipulation

Build an extension that inspects the final context sent to Qwen.

Then build controlled context injection.

I want tooling that lets me answer:

```text
What is currently in Qwen's context?

Where did each section come from?

How much context does it consume?

Why was it included?
```

Experiment with:

* system prompt additions
* project context
* skills
* session history
* temporary injected instructions
* duplicate instructions
* conflicting instructions
* stale context
* huge tool results

Create a context-inspector extension.

This should become a reusable debugging tool.

# Phase 6 — Tool policy

Separate:

```text
TOOL CAPABILITY
what a tool can technically do

TOOL POLICY
whether this agent is allowed to do it
```

Using Pi's extension/hooks system, build policies such as:

* unrestricted
* read-only
* deny shell
* allow selected shell commands
* path restrictions
* confirmation required
* deny destructive operations

Use the SAME tools with different policy layers.

Create at least two harness configurations where the only meaningful architectural difference is policy.

# Phase 7 — Derived feature: Plan Mode

Now build "plan mode."

Do NOT create a giant dedicated plan-mode subsystem.

Construct it from Pi primitives.

Possible composition:

```text
command
+
extension state
+
prompt/context mutation
+
tool restrictions
+
optional TUI indicator
```

Document:

```text
docs/concepts/derived-features.md
```

with:

```text
Plan Mode
=
...
```

This document should grow throughout the project.

# Phase 8 — Verification and receipts

Build a reusable verification extension.

Separate:

```text
Qwen says:
"I completed the task."
```

from:

```text
Harness evidence:
test command exited 0
expected file exists
expected output observed
```

Design a generic receipt/event structure.

Examples:

```text
COMMAND_EXECUTED
FILE_MODIFIED
TEST_PASSED
ARTIFACT_CREATED
TASK_CLAIMED_COMPLETE
```

Experiment with Qwen falsely claiming success.

The harness should be capable of detecting at least some unsupported completion claims.

# Phase 9 — Observability

Build strong observability before building more autonomy.

Record:

* timestamps
* model calls
* context size
* model latency
* generated tokens
* tool selection
* tool arguments
* tool output size
* errors
* retries
* state changes
* context changes
* verification events

Prefer structured JSON events with a human-readable formatter.

Eventually these traces should be usable by:

* terminal
* web interface
* dashboards
* evaluation scripts

# Phase 10 — Skills and reusable instruction modules

Explore Pi skills.

Understand:

* what a skill is
* when it is loaded
* how it alters context
* difference between skill and extension
* difference between tool and skill
* difference between skill and system prompt

Create a few small skills.

Then deliberately solve the same problem using:

```text
system prompt
vs
skill
vs
extension
vs
tool
```

Explain which is appropriate and why.

# Phase 11 — Context compaction experiments

Study Pi's context/session compaction behavior.

First observe Pi's existing behavior.

Do NOT replace it immediately.

Create experiments designed to break it.

Examples:

* long coding task
* huge command outputs
* many failed tool calls
* unresolved requirements early in conversation
* important verification evidence far back in history

Record what survives and what disappears.

Only after understanding Pi's behavior should we experiment with custom extensions or external memory mechanisms to compensate.

Create:

```text
experiments/context/compaction-torture-test/
```

# Phase 12 — Memory

Do not treat "memory" as one thing.

Explore separately:

* session transcript
* session summary
* explicit notes
* key-value memory
* semantic retrieval
* episodic records
* task state
* procedural instructions
* filesystem knowledge
* external database memory

Create at least two Pi-compatible memory approaches.

Examples:

```text
Pi extension + local SQLite
```

and:

```text
external Python memory service
        ↓
Pi tool
```

Compare the architectures.

Ask:

> Does this memory need to live inside Pi at all?

# Phase 13 — Sub-agents using Pi itself

Build sub-agents from Pi instances/processes rather than inventing an entirely separate agent abstraction.

Start with:

```text
parent Pi
    ↓
spawn child Pi
    ↓
give task
    ↓
capture result
    ↓
return to parent
```

Experiment with:

* separate session
* different system prompt
* different tool set
* restricted policy
* same Qwen model
* different models
* child transcripts
* failure
* timeout
* recursion limits

Then build:

```text
parent
  ├── researcher
  ├── coder
  └── reviewer
```

Do not assume this architecture is superior.

Evaluate it.

# Phase 14 — Harness architecture catalog

Using the same Pi runtime, create increasingly distinct configurations.

A harness definition should primarily be:

```text
Pi
+
extensions
+
skills
+
tools
+
policies
+
prompts
+
configuration
```

rather than a fork.

Create at least:

## minimal

As little additional behavior as possible.

## coding

Filesystem + shell + edit + verification.

## read-only analyst

Can inspect but not alter.

## researcher

Retrieval/search/evidence-oriented behavior.

## planner-executor

Explicit planning phase followed by execution.

## actor-verifier

One acting process/session and one verifying process/session.

## reviewer

Receives an artifact/task result and critiques it.

## low-context

Designed to minimize context usage.

## autonomous

Adds durable task state, verification and controlled continuation.

## experimental

For strange architectures.

Each harness should have a short architecture document showing its composition.

# Phase 15 — Same model, different harness experiment

This is a major milestone.

Create a benchmark task suite and run Qwen 3.8 through:

```text
Qwen + minimal Pi

Qwen + coding harness

Qwen + verification

Qwen + planner/executor

Qwen + actor/verifier

Qwen + multi-agent
```

Measure:

* completion rate
* tool calls
* failed tool calls
* unsupported success claims
* latency
* generated tokens
* context consumption
* human intervention
* recovery behavior

The purpose is to quantify how much behavior comes from:

```text
model
prompt
context
tools
policy
control flow
verification
orchestration
```

# Phase 16 — Pi controlled from Python

Now introduce Python.

Do not rewrite Pi.

Treat Pi as an agent worker/runtime.

Build a small Python controller using the most appropriate supported integration mechanism such as Pi's RPC/process/API interface.

Architecture:

```text
Python controller
      │
      ├── starts agent
      ├── sends task
      ├── receives events
      ├── tracks state
      └── receives result
              │
              ▼
             Pi
              │
             Qwen
```

Teach me what belongs in Python versus Pi.

Create a simple FastAPI or CLI controller.

# Phase 17 — Persistent autonomous task runner

Build the next layer outside Pi where appropriate.

Use Python for:

* durable task records
* scheduler
* task queue
* pause/resume
* retries
* checkpoints
* blockers
* external events
* crash recovery

Use Pi for:

* reasoning
* tool interaction
* task execution
* local agent state
* agent-specific context
* extensions

Keep this distinction explicit:

```text
Pi agent loop
≠
durable workflow engine
```

# Phase 18 — Blackboard architecture

Implement a simple blackboard externally.

Example:

```text
                  BLACKBOARD
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
   Pi worker A    Pi worker B   Pi worker C
       coder       researcher     reviewer
```

Use a simple database or structured shared state.

Start with the simplest possible implementation.

Explore:

* shared observations
* claims
* tasks
* artifacts
* agent ownership
* conflicts
* synchronization
* event-driven activation

Compare this to direct parent/child agent orchestration.

# Phase 19 — Other orchestration architectures

Implement or prototype several compositions using Pi workers:

### supervisor-worker

### planner-executor

### actor-verifier

### generator-critic

### pipeline

### map-reduce

### blackboard

### shared task queue

### specialist router

For each architecture create a concise document:

```text
STRUCTURE
STATE TOPOLOGY
COMMUNICATION TOPOLOGY
ADVANTAGES
FAILURE MODES
TOKEN COST
LATENCY
BEST USE CASE
```

Explicitly distinguish architectural differences from mere prompt-role differences.

# Phase 20 — Find Pi's boundaries

This phase is extremely important.

Deliberately try to implement difficult or unusual systems.

Ask:

```text
Is Pi helping?
Is Pi neutral?
Is Pi fighting us?
```

Document any friction involving:

* session model
* context lifecycle
* concurrency
* extension API
* orchestration
* model routing
* durability
* observability
* external state
* streaming
* parallelism
* subprocess control

Create:

```text
docs/pi-internals/boundaries.md
```

For every limitation classify it:

```text
A. Can be solved cleanly with an extension

B. Better solved outside Pi

C. Requires wrapping/replacing a Pi component

D. Fundamental architectural incompatibility
```

Do not abandon Pi merely because something requires an external service.

# Phase 21 — Optional: build a tiny harness from scratch

Only after completing substantial Pi experimentation, create a deliberately tiny Python agent harness for educational comparison.

Keep it minimal:

```text
OpenAI-compatible Qwen call
+
messages
+
tool schema
+
tool execution
+
loop
```

The goal is NOT replacing Pi.

The goal is understanding what Pi is saving us from implementing.

Compare:

```text
our ~small Python loop
vs
Pi runtime
```

Document every capability Pi adds beyond the minimal loop.

# Living primitive catalog

Maintain:

```text
docs/concepts/primitives.md
```

For each Pi primitive or conceptual primitive record:

* name
* purpose
* minimal mental model
* API/mechanism
* state ownership
* inputs
* outputs
* lifecycle
* failure modes
* what it should NOT do
* common compositions

Also maintain:

```text
docs/concepts/derived-features.md
```

Examples:

```text
Plan Mode
=
state
+ context modification
+ policy
+ command
```

```text
Approval Gate
=
before-tool hook
+ policy
+ user interaction
+ state
```

```text
Verification
=
events
+ receipts
+ environment observation
+ completion policy
```

```text
Sub-agent
=
Pi instance
+ isolated session
+ task prompt
+ tool/policy configuration
+ result transport
```

```text
Persistent Autonomous Agent
=
Pi worker
+ durable external task state
+ scheduler
+ recovery
+ verification
```

# Experiments with Qwen 3.8

Use Qwen 3.8 throughout as the primary experimental model.

Create controlled tests for:

* tool selection
* wrong tool selection
* malformed tool arguments
* repeated failed commands
* large tool output
* context saturation
* forgotten instructions
* long tasks
* plan adherence
* verification
* hallucinated completion
* self-correction
* role separation
* sub-agent delegation
* retries
* state persistence
* context compaction
* parallel work

Whenever possible, first try to improve behavior through harness structure rather than simply adding a huge system prompt.

# TypeScript rule

Use TypeScript where Pi requires or strongly benefits from it.

Use Python where system-level orchestration is clearer.

Do not rewrite Python services in TypeScript merely for consistency.

A likely long-term architecture could be:

```text
Python
├── FastAPI
├── scheduler
├── task state
├── database
├── blackboard
├── metrics
└── orchestration
        │
        ▼
Pi workers
├── extensions
├── tools
├── context
├── session
└── policies
        │
        ▼
Qwen 3.8
```

Treat crossing the Python/Pi boundary as an architectural decision worth studying.

# Avoid premature framework building

Do not create a giant abstraction like:

```text
UniversalAgentFramework
MegaAgentManager
AgentFactoryFactory
```

Prefer concrete experiments first.

Abstract only after the same pattern has appeared multiple times.

Prefer:

* small extensions
* explicit configuration
* composition
* inspectable state
* structured events
* simple data structures
* documented architectural boundaries

Avoid:

* hidden global state
* inheritance-heavy designs
* magical decorators
* giant Agent classes
* unnecessary dependency injection frameworks
* abstractions that exist only because they sound architectural

# Learning lab format

Every lab should include:

## Objective

What I should understand.

## Pi primitive

What Pi capability we are learning.

## Mental model

Explain it simply.

## TypeScript needed

Only the TypeScript concepts required for this lab.

## Implementation

What we build.

## Inspect

What logs/source/state I should inspect.

## Experiment

A Qwen task to run.

## Break it

A failure to deliberately trigger.

## Explain

Questions I should be able to answer afterward.

## Reusable artifact

What code survives and becomes part of the repository.

## Completion criteria

Concrete conditions for considering the lab complete.

# Make me inspect Pi source code

At important points, point me to the relevant Pi implementation.

Do not merely tell me what Pi does.

Have me inspect small, targeted areas of Pi source relating to:

* agent loop
* tools
* extensions
* sessions
* context building
* lifecycle events
* compaction
* model provider layer
* RPC/external integration

Explain what to look for.

Avoid sending me through thousands of lines without a specific question.

# Git workflow

Each lab should leave the repository working.

Use clear commits such as:

```text
lab-01: establish minimal pi qwen setup
lab-02: add custom tool extension
lab-03: trace pi lifecycle
lab-04: add extension state
```

Preserve experiments instead of overwriting them.

# Documentation-first experimentation

Whenever we discover something surprising, write it down.

Maintain:

```text
docs/findings/pi-findings.md
```

and:

```text
docs/findings/qwen-findings.md
```

Examples:

```text
Qwen repeatedly chooses X under condition Y.

Pi compaction loses Z under this workload.

Verification extension prevents failure mode A.

Planner/executor adds latency without improving benchmark B.
```

I want the repository to become accumulated empirical knowledge, not just code.

# Initial task

Do NOT implement the whole roadmap.

Start by:

1. inspecting the empty repository,
2. creating the overall curriculum,
3. proposing the repository structure,
4. creating the primitive taxonomy,
5. creating `derived-features.md`,
6. creating the initial TypeScript survival guide,
7. identifying the Pi APIs/source areas that will matter most,
8. creating Lab 1,
9. configuring Pi to use my local Qwen 3.8 endpoint,
10. making Lab 1 demonstrate the most stripped-down useful Pi interaction possible,
11. adding instrumentation so we can inspect what Qwen actually receives where feasible,
12. documenting what comes from Qwen versus what comes from Pi,
13. stopping at a clear checkpoint.

Do NOT proceed to Lab 2 automatically.

At the checkpoint, I should be able to explain:

* what Pi is responsible for,
* what Qwen is responsible for,
* what a harness is,
* what a primitive is,
* what an extension is,
* what Pi gives us that a raw model API does not,
* and where my own architecture will eventually sit relative to Pi.

The long-term goal is not "build another coding agent."

The goal is to create an **agent architecture laboratory built around Pi**, eventually containing a catalog of reusable agent/harness configurations and a Python orchestration layer capable of combining Pi workers into much larger systems.
