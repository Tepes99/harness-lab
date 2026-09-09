import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

async function runChild(task: string, signal?: AbortSignal): Promise<{ output: string; events: unknown[] }> {
  const depth = Number(process.env.HARNESS_SUBAGENT_DEPTH ?? "0");
  if (depth >= 1) throw new Error("Sub-agent recursion limit reached");
  const args = ["--provider", "home-vllm", "--model", "qwen3.8-27b-fp8", "--thinking", "off", "--mode", "json", "--print", "--no-session", "--no-tools", "--no-extensions", "--no-skills", "--no-prompt-templates", "--no-themes", "--no-context-files", "--system-prompt", "You are an isolated child worker. Return a concise grounded result.", "--", task];
  const child = spawn("pi", args, { env: { ...process.env, HARNESS_SUBAGENT_DEPTH: String(depth + 1) }, stdio: ["ignore", "pipe", "pipe"] });
  signal?.addEventListener("abort", () => child.kill("SIGTERM"), { once: true });
  let stdout = "", stderr = "";
  child.stdout.on("data", chunk => { stdout += chunk.toString(); }); child.stderr.on("data", chunk => { stderr += chunk.toString(); });
  const exitCode = await new Promise<number | null>((resolve, reject) => { child.on("close", resolve); child.on("error", reject); });
  if (exitCode !== 0) throw new Error(`Child Pi failed (${exitCode}): ${stderr.slice(0, 500)}`);
  const events = stdout.split("\n").filter(Boolean).map(line => JSON.parse(line));
  const messages = events.filter((event): event is { type: string; message: { role: string; stopReason?: string; content: Array<{ type: string; text?: string }> } } => typeof event === "object" && event !== null && (event as { type?: string }).type === "message_end");
  const final = messages.filter(e => e.message.role === "assistant" && e.message.stopReason === "stop").at(-1);
  const output = final?.message.content.filter(part => part.type === "text").map(part => part.text ?? "").join("") ?? "";
  return { output, events };
}

export default function subagent(pi: ExtensionAPI): void {
  pi.registerTool({ name: "delegate_once", label: "Delegate Once", description: "Run one task in an isolated child Pi process with no tools or session.", parameters: Type.Object({ task: Type.String({ minLength: 1, maxLength: 1000 }) }), async execute(_id, params, signal) {
    const result = await runChild(params.task, signal);
    return { content: [{ type: "text", text: result.output }], details: { childEventCount: result.events.length, isolatedSession: true } };
  }});
}
