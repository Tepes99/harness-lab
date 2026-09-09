# Context pipeline

Context is the information available to one model call. It is rebuilt for every turn and is not synonymous with the complete session file.

```text
CLI/config/resources
  ├── custom/default system prompt
  ├── active tool descriptions and schemas
  ├── cwd
  ├── project context files
  └── skill metadata
          ↓ Pi system-prompt builder
session active branch + current input + extension messages
          ↓ Pi session context projection
before_agent_start changes
          ↓
context-hook message transformations
          ↓
provider adapter serialization
          ↓ before_provider_request: closest Pi-side payload
vLLM chat template + tokenization
          ↓
Qwen token context
```

## Inspection stages

| Stage | What it answers | What can still change afterward |
|---|---|---|
| `before_agent_start.systemPromptOptions` | Which prompt inputs, tools, files, skills, and cwd Pi loaded | Later pre-agent handlers can change the prompt or inject messages |
| `before_agent_start.systemPrompt` | Pi’s assembled prompt at this handler’s position | Later handlers and provider serialization |
| `context.messages` | Pi’s per-turn message projection after pre-agent injection | Later context handlers and provider conversion |
| `before_provider_request.payload` | Provider-specific body immediately before this hook returns | Later provider-request handlers; then vLLM template/tokenization |
| Assistant `usage.input` | Provider-reported input tokens after a completed call | Reporting quality depends on provider implementation |

The reusable [`context-inspector.ts`](../../extensions/observability/context-inspector.ts) records all four Pi-side observations. It includes exact payloads only in ignored `.lab-output` files, because prompts and context files may be sensitive.

## Source and size

The inspector labels system-prompt inputs using Pi’s structured options and labels messages by role. Its character-divided-by-four token figure is deliberately marked approximate; tokenizer behavior, JSON/provider framing, tool schemas, images, and Qwen’s chat template make exact preflight counts model-specific. Prefer provider-reported usage after the call when available.

Tool definitions are request context even though they are not message entries. Custom session entries are durable state but do not become model messages. Custom messages do enter context and are serialized according to the provider adapter.

## Mutation rules

`before_agent_start` can add a persistent custom message or replace the system prompt for the run. `context` can return a changed message list for one model call without rewriting the transcript. `before_provider_request` can replace the serialized payload. The later the mutation, the more provider-specific and less visible it is to higher-level Pi inspection.

Duplicate or conflicting instructions have no universal semantic resolution. Pi establishes construction and handler order; Qwen decides how to respond to the resulting text. Policy must not rely on Qwen resolving conflicts in the desired direction.

