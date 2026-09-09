# Derived features

Derived features are named compositions. The equations below are design hypotheses to test, not hidden framework classes to implement.

```text
Plan Mode
= command
+ extension-owned mode state
+ system-prompt/context mutation
+ tool policy
+ optional TUI status
```

```text
Approval Gate
= before-tool hook
+ policy decision
+ user interaction
+ decision state or receipt
```

```text
Verification
= task claim
+ environment observation tools
+ structured receipts
+ completion policy
```

```text
Sub-agent
= Pi process or instance
+ isolated session
+ task prompt
+ tool/policy configuration
+ result and event transport
```

```text
Reviewer
= separate Pi session/process
+ read-only artifact context
+ review rubric
+ structured findings transport
```

```text
Persistent Autonomous Agent
= Pi worker
+ durable external task state
+ scheduler
+ recovery rules
+ verification
```

```text
Blackboard System
= shared durable state
+ multiple Pi workers
+ claim/ownership protocol
+ activation rule
+ conflict handling
```

The key diagnostic is to change one term while holding the model fixed. A “planner” created only by renaming the system prompt is a prompt-role experiment. A planner/executor architecture exists when control flow, state, context, or permissions differ between phases.

