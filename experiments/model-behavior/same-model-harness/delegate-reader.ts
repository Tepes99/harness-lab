import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function delegateReader(pi: ExtensionAPI): void {
  pi.registerTool({
    name: "delegate_reader",
    label: "Delegate Reader",
    description: "Delegate one evidence-reading task to an isolated child Pi that only has the read tool.",
    parameters: Type.Object({ task: Type.String({ minLength: 1 }) }, { additionalProperties: false }),
    async execute(_id, { task }, signal) {
      const args = ["--provider", "home-vllm", "--model", "qwen3.8-27b-fp8", "--thinking", "off", "--mode", "json", "--print", "--no-session", "--tools", "read", "--no-extensions", "--no-skills", "--no-prompt-templates", "--no-themes", "--no-context-files", "--system-prompt", "Use read for the requested evidence and return only the answer.", "--", task];
      const child = spawn("pi", args, { cwd: process.cwd(), stdio: ["ignore", "pipe", "pipe"] });
      const chunks: Buffer[] = []; const errors: Buffer[] = [];
      child.stdout.on("data", (chunk) => chunks.push(chunk)); child.stderr.on("data", (chunk) => errors.push(chunk));
      const abort = () => child.kill("SIGTERM"); signal.addEventListener("abort", abort, { once: true });
      const code = await new Promise<number | null>((resolve, reject) => { child.on("close", resolve); child.on("error", reject); });
      signal.removeEventListener("abort", abort);
      if (code !== 0) throw new Error(`child Pi failed (${code}): ${Buffer.concat(errors).toString("utf8")}`);
      const events = Buffer.concat(chunks).toString("utf8").trim().split("\n").filter(Boolean).map(JSON.parse);
      const childReadObserved = events.some((event) => event.type === "tool_execution_end" && event.toolName === "read" && !event.isError);
      const assistant = events.filter((event) => event.type === "message_end" && event.message?.role === "assistant").at(-1);
      const text = assistant?.message?.content?.find((part: { type: string; text?: string }) => part.type === "text")?.text ?? "";
      return { content: [{ type: "text", text }], details: { childReadObserved, childEventCount: events.length } };
    },
  });
}
