# Lab 4 — Extension-owned state

## Objective

Distinguish ephemeral variables, Pi session entries, model context, and external durable storage by watching one counter survive destruction of its extension process.

## Pi primitive

Pi’s append-only session tree stores messages, tool-result `details`, and namespaced custom entries. `session_start`, `session_tree`, and `SessionManager.getBranch()` let an extension reconstruct branch-local state.

## Mental model

```text
Pi process A: count 0 → tool increments to 7 → snapshot enters session JSONL → exits
Pi process B: new module instance → scans active branch → restores 7 → tool reads 7
```

The new `instanceId` proves process-local memory did not survive. The session snapshot did.

## TypeScript needed

Read the survival guide’s state-restoration section. The `isCounterSnapshot` type guard validates unknown JSON before TypeScript narrows it. Interfaces disappear at runtime, so `schemaVersion` plus field checks protect restoration.

## Implementation

[`counter.ts`](counter.ts) registers `lab_counter`. Its in-memory state is reconstructed from the latest valid tool-result details on the active branch. Every call also appends a namespaced, model-invisible custom audit entry. A separate JSONL audit exists only to make process instance changes easy to verify.

```bash
npm run check
npm run lab:04
```

The script creates a unique session under `.lab-output`, increments by seven in one Pi process, exits, then starts another Pi process on the same session and reads the count.

## Inspect

The script prints both external audit records and relevant session entries. Confirm:

- Two distinct `instanceId` values exist.
- The first restore starts at zero.
- The second restore finds count seven before its read tool executes.
- Tool-result details contain a complete snapshot.
- `lab-04-counter-audit` entries are type `custom`, not messages.
- The provider request traces contain neither the custom-entry namespace nor the ephemeral instance IDs.

Read installed `dist/core/session-manager.js` around `appendCustomEntry`, `getBranch`, and `buildSessionContext`. Locate the code that excludes plain custom entries from model context.

## Experiment

Change only `--session-id` for the second invocation; the counter should start at zero. Then reuse the original session again; it should restore seven. This demonstrates that extension state is namespaced by session history rather than global process state.

## Break it

Copy a generated session to a disposable path and change the latest snapshot’s `schemaVersion` to `999`. Resume the disposable copy. The runtime guard should reject it and fall back to the preceding valid snapshot or zero. Never edit the baseline trace.

In interactive mode, fork before the increment and switch branches. Verify that `getBranch()` restores the state belonging to the selected path.

## Explain

1. Which state survives a process restart, and why?
2. Why does `getBranch()` matter more than `getEntries()`?
3. Why are TypeScript interfaces insufficient when reading session JSON?
4. Which persisted fields enter Qwen context?
5. When would SQLite or a Python service be a better owner?
6. How do schema versions support extension evolution?

## Reusable artifact

The versioned snapshot, runtime guard, and branch reconstruction pattern will inform later stateful extensions. The counter itself remains a lab fixture.

## Completion criteria

- Two separate Pi processes use one session.
- The second process restores count seven before executing its read.
- Distinct instance IDs prove ephemeral state restarted.
- Session JSONL contains both tool-result details and namespaced custom entries.
- The four state/context stores can be explained without calling them all “memory.”
