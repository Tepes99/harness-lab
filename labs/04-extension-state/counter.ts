import { appendFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { randomUUID } from "node:crypto";
import { StringEnum } from "@earendil-works/pi-ai";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

interface CounterSnapshot {
  schemaVersion: 1;
  count: number;
  mutationCount: number;
}

interface CounterDetails extends CounterSnapshot {
  action: "read" | "increment";
  instanceId: string;
}

function isCounterSnapshot(value: unknown): value is CounterSnapshot {
  if (typeof value !== "object" || value === null) return false;
  const candidate = value as Record<string, unknown>;
  return (
    candidate.schemaVersion === 1 &&
    typeof candidate.count === "number" &&
    Number.isFinite(candidate.count) &&
    typeof candidate.mutationCount === "number" &&
    Number.isInteger(candidate.mutationCount)
  );
}

export default function counterExtension(pi: ExtensionAPI): void {
  const instanceId = randomUUID();
  let state: CounterSnapshot = {
    schemaVersion: 1,
    count: 0,
    mutationCount: 0,
  };
  const auditPath = resolve(
    process.env.HARNESS_LAB_STATE_AUDIT ??
      ".lab-output/lab-04/manual.state-audit.jsonl",
  );
  mkdirSync(dirname(auditPath), { recursive: true });

  const audit = (event: string, data: Record<string, unknown>): void => {
    appendFileSync(
      auditPath,
      `${JSON.stringify({ timestamp: new Date().toISOString(), event, instanceId, ...data })}\n`,
      "utf8",
    );
  };

  const restoreFromBranch = (ctx: ExtensionContext): void => {
    state = { schemaVersion: 1, count: 0, mutationCount: 0 };
    let restoredFromEntryId: string | null = null;

    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type !== "message") continue;
      const message = entry.message;
      if (message.role !== "toolResult" || message.toolName !== "lab_counter") {
        continue;
      }
      if (isCounterSnapshot(message.details)) {
        state = {
          schemaVersion: 1,
          count: message.details.count,
          mutationCount: message.details.mutationCount,
        };
        restoredFromEntryId = entry.id;
      }
    }

    audit("state_restored", {
      state,
      restoredFromEntryId,
      branchEntryCount: ctx.sessionManager.getBranch().length,
    });
  };

  pi.on("session_start", (_event, ctx) => restoreFromBranch(ctx));
  pi.on("session_tree", (_event, ctx) => restoreFromBranch(ctx));

  pi.registerTool({
    name: "lab_counter",
    label: "Lab Counter",
    description: "Read or increment a counter whose snapshots are restored from the active Pi session branch.",
    promptSnippet: "Read or increment branch-local extension state",
    parameters: Type.Object(
      {
        action: StringEnum(["read", "increment"] as const),
        amount: Type.Optional(Type.Integer({ minimum: 1, maximum: 100 })),
      },
      { additionalProperties: false },
    ),
    async execute(_toolCallId, params) {
      if (params.action === "increment") {
        state = {
          schemaVersion: 1,
          count: state.count + (params.amount ?? 1),
          mutationCount: state.mutationCount + 1,
        };
      }

      const details: CounterDetails = {
        ...state,
        action: params.action,
        instanceId,
      };

      pi.appendEntry("lab-04-counter-audit", {
        schemaVersion: 1,
        action: params.action,
        state: { ...state },
        instanceId,
      });
      audit("tool_executed", { action: params.action, state });

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify({
              action: params.action,
              count: state.count,
              mutationCount: state.mutationCount,
            }),
          },
        ],
        details,
      };
    },
  });
}
