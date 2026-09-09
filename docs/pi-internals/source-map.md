# Pi source-reading map

The installed runtime is `@earendil-works/pi-coding-agent` 0.85.1 from `github.com/earendil-works/pi`, with its package source under `packages/coding-agent`. The global install also contains compiled JavaScript and source maps. Run `scripts/check-pi-environment.sh` to resolve the local package path instead of assuming a particular Node version directory.

Read these small areas with a question in mind:

| Question | Upstream source | Installed artifact to inspect now |
|---|---|---|
| How is the system prompt assembled from tools, context files, skills, and cwd? | `packages/coding-agent/src/core/system-prompt.ts` | `dist/core/system-prompt.js` |
| Where are one run, retries, compaction, messages, tools, and extensions coordinated? | `packages/coding-agent/src/core/agent-session.ts` | `dist/core/agent-session.js` |
| How does an extension hook run and how are returned mutations chained? | `packages/coding-agent/src/core/extensions/runner.ts` | `dist/core/extensions/runner.js` |
| Which event and extension contracts are public? | `packages/coding-agent/src/core/extensions/types.ts` | `dist/core/extensions/types.d.ts` |
| How are project/global extensions and resources discovered? | `packages/coding-agent/src/core/extensions/loader.ts` and `core/resource-loader.ts` | matching `dist/core/*.js` files |
| How are session entries stored and reconstructed? | `packages/coding-agent/src/core/session-manager.ts` | `dist/core/session-manager.js` |
| How are provider configuration and credentials resolved? | `packages/coding-agent/src/core/model-runtime.ts` | `dist/core/model-runtime.js` |
| What do built-in tools expose? | `packages/coding-agent/src/core/tools/index.ts` | `dist/core/tools/index.js` |
| How will Python later control Pi? | `packages/coding-agent/src/modes/rpc/` and `src/core/sdk.ts` | `dist/modes/rpc/` and `dist/core/sdk.js` |
| What gets summarized during compaction? | `packages/coding-agent/src/core/compaction/` | `dist/core/compaction/` |

## Lab 1 reading exercise

Open `system-prompt.js` and answer:

1. What does Pi append even when `--system-prompt` replaces its default prompt?
2. Under what condition are context files included?
3. Under what condition are skills included?
4. How does the active tool list alter the default prompt?

Then open the `before_provider_request` implementation in `extensions/runner.js`. Confirm that handlers run in extension load order and that a non-`undefined` return replaces the payload. The Lab 1 recorder returns nothing, so it observes without mutation.

