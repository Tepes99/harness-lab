import { appendFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function toolPolicy(pi: ExtensionAPI): void {
  const mode = process.env.HARNESS_TOOL_POLICY ?? "unrestricted";
  const auditPath = resolve(process.env.HARNESS_TOOL_POLICY_AUDIT ?? ".lab-output/policy/manual.jsonl");
  mkdirSync(dirname(auditPath), { recursive: true });

  pi.on("tool_call", (event) => {
    const blocked = mode === "read-only" && event.toolName === "lab_write_marker";
    appendFileSync(auditPath, `${JSON.stringify({ mode, toolName: event.toolName, blocked })}\n`, "utf8");
    if (blocked) return { block: true, reason: "Read-only policy denies lab_write_marker" };
  });
}
