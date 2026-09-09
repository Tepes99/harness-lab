import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function planMode(pi: ExtensionAPI): void {
  let enabled = false;
  pi.registerFlag("plan", { description: "Start in plan mode", type: "boolean", default: false });
  const persist = () => pi.appendEntry("lab-07-plan-mode", { schemaVersion: 1, enabled });
  pi.registerCommand("plan", {
    description: "Toggle plan mode",
    handler: async (_args, ctx) => {
      enabled = !enabled; persist(); ctx.ui.setStatus("lab-plan", enabled ? "PLAN" : undefined);
    },
  });
  pi.on("session_start", (_event, ctx) => {
    enabled = pi.getFlag("plan") === true;
    for (const entry of ctx.sessionManager.getBranch()) {
      if (entry.type === "custom" && entry.customType === "lab-07-plan-mode") {
        const data = entry.data as { enabled?: unknown } | undefined;
        if (typeof data?.enabled === "boolean") enabled = data.enabled;
      }
    }
    if (ctx.hasUI) ctx.ui.setStatus("lab-plan", enabled ? "PLAN" : undefined);
  });
  pi.on("before_agent_start", () => enabled ? { message: { customType: "lab-07-plan-context", display: false, content: "[PLAN MODE] Analyze and return a numbered plan. Do not execute mutations." } } : undefined);
  pi.on("tool_call", (event) => {
    if (enabled && event.toolName === "lab_write_marker") return { block: true, reason: "Plan mode blocks mutation tools" };
  });
}
