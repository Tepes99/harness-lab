# Tool capability and policy

```text
capability = code that can perform an action
policy     = decision about whether this configured agent may perform it
```

Lab 6 loads the same `lab_write_marker` definition in both cases. The unrestricted policy lets Pi dispatch it; the read-only policy blocks it in `tool_call` before the executor. Removing a tool from the active set is stronger minimization when it is never needed; interception is useful when permission depends on mode, path, arguments, or human approval.

Prompt instructions are context, not policy. Qwen can ignore text. A `tool_call` hook returns a harness decision that Pi enforces. Policy logs should record decisions without leaking secrets, and input mutation deserves special scrutiny because Pi does not revalidate arguments after a hook changes them.
