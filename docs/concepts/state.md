# State ownership and restoration

“Memory” is too broad to design directly. Lab 4 separates four stores that happen to contain related facts.

| Store | Lab 4 example | Lifetime | Sent to Qwen? | Owner |
|---|---|---|---|---|
| Ephemeral extension state | Module variable and random `instanceId` | One extension instance/process | Only if the extension puts it in a message/result | Extension |
| Session transcript | User, assistant tool-call, and `toolResult` messages | Persisted Pi session and active branch | Context builder selects message content | Pi `SessionManager` |
| Extension session state | Versioned counter snapshot in tool-result `details`; namespaced custom audit entry | Persisted session branch | `details` and plain custom entries are not provider message content | Extension data inside Pi session |
| External filesystem/database state | Lab-only state audit JSONL | Independent of Pi session | No, unless retrieved and injected | Lab/external architecture |

```text
model context
≠ session transcript
≠ extension's in-memory object
≠ session-persisted extension snapshot
≠ external file or database
```

## Why restore from tool-result details

Pi sessions are append-only trees. Each successful `lab_counter` tool result stores a complete, versioned snapshot in `details`. On `session_start` and `session_tree`, the extension scans `getBranch()` and adopts the latest valid snapshot. Using the active branch preserves fork/tree semantics; scanning every entry could restore state from an abandoned branch.

The extension also appends a namespaced `lab-04-counter-audit` custom entry to demonstrate durable extension-only session data. Plain custom entries do not participate in model context. The duplicate is pedagogical: the tool-result snapshot drives restoration because Pi’s own extension guide recommends that approach for tool-owned branching state.

## Serialization rules

- Store plain JSON-compatible values, not class instances, open handles, or callbacks.
- Include `schemaVersion` and validate runtime data before trusting it.
- Copy arrays/objects into snapshots so later mutation does not alter the intended record.
- Treat custom type names as a namespace owned by one extension.
- Rebuild in-memory state during session start, reload, resume, fork, and tree changes as applicable.

Persistence records history; it does not decide what Qwen sees. Context construction remains a separate mechanism.

