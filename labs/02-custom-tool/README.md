# Lab 2 — Custom tools and the validation boundary

## Objective

Understand how a Qwen tool proposal becomes validated input, executed TypeScript, a structured result, and another model turn.

## Pi primitive

`pi.registerTool()` gives Pi a name, model-facing description, runtime TypeBox schema, and executor. Pi owns schema validation and loop continuation; the extension owns tool semantics; Qwen chooses whether and how to propose a call.

## Mental model

```text
Qwen proposes name + JSON arguments
  → Pi finds the registered tool
  → Pi validates arguments against TypeBox
  → extension execute() runs
  → Pi adds a toolResult message
  → Qwen receives the result in the next turn
```

## TypeScript needed

Read the new survival-guide sections on async functions, interfaces, optional properties, runtime schemas, `AbortSignal`, and thrown errors. Compare `async execute(...): Promise<Result>` with an async Python framework handler. The TypeBox value is runtime validation; the inferred TypeScript type is editor/compiler help.

## Implementation

[`tools.ts`](tools.ts) registers:

- `structured_echo`, a deliberately trivial tool with a non-empty string and bounded repeat count.
- `workspace_inventory`, a useful read-only tool that counts files, directories, and extensions without reading file contents. It stays inside the workspace, skips `.git` and `node_modules` recursion, limits depth to three, caps entries at 5,000, and cooperates with cancellation.

Run both controlled cases:

```bash
npm run check
npm run lab:02
./labs/02-custom-tool/inspect.sh
```

The request recorder from Lab 1 captures provider payloads. Pi’s JSON mode captures tool lifecycle events and complete tool results.

## Inspect

In the first provider payload, find `tools[].function.parameters`; this is the schema Qwen sees. In the Pi event stream, follow `tool_execution_start`, the assistant tool-call message, `tool_execution_end`, the `toolResult` message, and the second `turn_start`. Compare model-visible `content` with extension-owned `details`.

Inspect Pi’s installed `dist/core/extensions/types.d.ts` for `ToolDefinition`, then `dist/core/agent-session.js` for `_installAgentToolHooks`. Ask where validation occurs relative to `execute` and where thrown errors become `isError: true`.

## Experiment

Hold the model and tools fixed, then change only the tool descriptions. Record whether Qwen’s selection changes. Next disable `workspace_inventory` with `--tools structured_echo`; its code still exists, but its capability is no longer exposed in this harness.

## Break it

Ask Qwen to call `structured_echo` with `repeat: 99`, a missing `message`, and an unexpected property in three separate runs. A malformed proposal should fail schema validation before `execute`. Then request `workspace_inventory` with `path: "../"`; the schema accepts a string, but domain validation in the executor throws. These demonstrate two different failure boundaries.

## Explain

1. Which part of a tool definition is shown to Qwen?
2. Which validation happens before extension code executes?
3. Why is TypeScript’s inferred parameter type insufficient at runtime?
4. Why does throwing differ from returning error-looking text?
5. Why is a registered capability not the same as permission to use it?
6. What enters the next model context after a successful call?

## Reusable artifact

The bounded `workspace_inventory` pattern—path confinement, depth/size limits, cancellation, structured details—is a candidate for later promotion after policy experiments. The echo remains a protocol fixture.

## Completion criteria

- Both tools type-check and appear in the provider tool schema.
- Qwen successfully calls each tool and receives its result.
- Each tool call creates a second model turn.
- At least one schema-validation failure and one executor-thrown failure can be distinguished.
- The model/tool/Pi ownership boundary can be explained from trace evidence.
