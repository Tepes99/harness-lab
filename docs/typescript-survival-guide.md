# TypeScript survival guide for Pi extensions

This guide starts with only the concepts used by Lab 1. Later labs should extend it when their code introduces a new language feature.

## Runtime versus type checker

Pi loads extension `.ts` files through its TypeScript loader, so an extension does not need a manual compile step. `npm run check` runs TypeScript separately to catch mistakes before Pi loads the file.

TypeScript types disappear at runtime. They help the editor and compiler but do not validate network data or model-generated tool arguments. Later tool labs will use a runtime schema for that job.

```text
Python type hint             TypeScript type annotation
path: str                    path: string

Pydantic validation          runtime schema validation
(runs on data)               (runs on data)

TypeScript interface
(compile-time only)
```

## Imports

Lab 1 imports Node filesystem functions and one Pi type:

```typescript
import { appendFileSync, mkdirSync } from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
```

`import type` tells TypeScript that `ExtensionAPI` is for checking only. It emits no runtime import. This matters because the running Pi process already supplies the extension API object.

## Constants and objects

Use `const` when the binding will not be reassigned. An object bound with `const` may still contain changing data.

```typescript
const record = {
  timestamp: new Date().toISOString(),
  event: "session_start",
};
```

This resembles a Python dictionary, but TypeScript infers a compile-time shape from the object literal.

## Functions and callbacks

A Pi extension exports a factory function. Pi calls it and passes its API:

```typescript
export default function requestRecorder(pi: ExtensionAPI): void {
  pi.on("agent_start", () => {
    // This arrow function is a callback Pi invokes later.
  });
}
```

Python comparison:

```python
def request_recorder(pi):
    pi.on("agent_start", lambda: None)
```

The event name selects a typed callback signature. TypeScript then knows which fields exist on `event` and `ctx`.

## Union narrowing

Pi messages use a discriminated union: the `role` field identifies the variant. Check it before accessing variant-specific fields.

```typescript
if (event.message.role === "assistant") {
  const usage = event.message.usage;
}
```

This is similar to checking a tagged Pydantic model’s discriminator before using subtype fields.

## Unknown and JSON

The final provider payload has type `unknown` because each provider can produce a different shape. It is safe to serialize an unknown value:

```typescript
const line = JSON.stringify(event.payload);
```

It is unsafe to access `event.payload.messages` until runtime checks establish that the payload is an object with that property. Lab 1 records the value without pretending its shape is guaranteed.

## Filesystem and errors

Node’s `node:fs` module is the standard-library equivalent of Python’s `pathlib`/file operations. The recorder creates its output directory once and appends one JSON object per line. Synchronous writes are acceptable here because they are tiny and ordering is more valuable than throughput in a learning trace.

```typescript
try {
  appendFileSync(path, line + "\n", "utf8");
} catch (error: unknown) {
  const message = error instanceof Error ? error.message : String(error);
  console.error(message);
}
```

`unknown` in the catch clause forces an explicit check before treating the value as an `Error`.

## Next concepts, when needed

## Async functions and Promises

Pi tool executors are asynchronous because tools often read files, start processes, or call services:

```typescript
async function inspect(): Promise<string[]> {
  return await readdir(".");
}
```

This is the direct analogue of Python’s `async def`. An `async` TypeScript function always returns a `Promise<T>`, analogous to a Python coroutine that eventually produces `T`. `await` unwraps that future result or throws its rejection.

## Interfaces and optional properties

An interface names a compile-time object shape:

```typescript
interface Inventory {
  files: number;
  warning?: string;
}
```

The `?` means `warning` may be absent. It does not fill a default or validate data at runtime.

## Runtime schemas

Tool arguments originate with the model, so compile-time types cannot protect the executor. Pi accepts a TypeBox schema and validates a proposed call before invoking `execute`:

```typescript
const Parameters = Type.Object(
  { message: Type.String({ minLength: 1 }) },
  { additionalProperties: false },
);
```

TypeBox describes runtime JSON. Pi derives the executor’s parameter type from that schema, so one definition serves runtime validation and TypeScript.

## AbortSignal

Long-running tools receive an optional `AbortSignal`. Check it inside loops and throw its reason when cancellation is requested:

```typescript
if (signal?.aborted) {
  throw signal.reason ?? new Error("Cancelled");
}
```

This resembles periodically checking a Python cancellation event. It cooperates with cancellation; it cannot forcibly stop arbitrary synchronous work.

## Structured tool results and thrown errors

A successful tool returns content for the model plus optional `details` for rendering, state, or audit code. To make Pi mark a tool result as an error, throw an `Error`; returning text that begins with “Error” is still a successful tool result.

## State reconstruction and runtime guards

Session JSON is runtime data, even when this repository originally wrote it. Casts such as `entry.data as CounterState` silence the compiler but do not verify old or corrupt data. Check discriminator and field types before restoring:

```typescript
function isCounterState(value: unknown): value is CounterState {
  return typeof value === "object" && value !== null &&
    "count" in value && typeof value.count === "number";
}
```

The `value is CounterState` return type is a user-defined type guard. When it returns true, TypeScript narrows `value` inside the calling branch. This resembles validating a Python dictionary before constructing a typed domain object.

State reconstructed from an append-only branch should use a new object rather than retain mutable references from parsed session entries. Persist a `schemaVersion` so later code can migrate older snapshots deliberately.

Later labs add context-event transformations. Child processes and more advanced generics should wait until a lab actually uses them.
