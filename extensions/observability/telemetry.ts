import { appendFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function telemetry(pi: ExtensionAPI): void {
  const path = resolve(process.env.HARNESS_TELEMETRY_FILE ?? ".lab-output/telemetry/manual.jsonl");
  mkdirSync(dirname(path), { recursive: true });
  const starts = new Map<string, number>();
  let requestStarted = 0;
  const emit = (type: string, data: Record<string, unknown>) =>
    appendFileSync(path, `${JSON.stringify({ timestamp: new Date().toISOString(), type, ...data })}\n`);

  pi.on("context", (event) => emit("CONTEXT_BUILT", { messages: event.messages.length, bytes: Buffer.byteLength(JSON.stringify(event.messages)) }));
  pi.on("before_provider_request", (event) => {
    requestStarted = performance.now();
    emit("MODEL_REQUEST", { bytes: Buffer.byteLength(JSON.stringify(event.payload)) });
  });
  pi.on("after_provider_response", (event) => emit("PROVIDER_RESPONSE", { status: event.status, headersLatencyMs: Math.round(performance.now() - requestStarted) }));
  pi.on("tool_execution_start", (event) => {
    starts.set(event.toolCallId, performance.now());
    emit("TOOL_SELECTED", { toolCallId: event.toolCallId, tool: event.toolName, arguments: event.args });
  });
  pi.on("tool_execution_end", (event) => emit("TOOL_FINISHED", {
    toolCallId: event.toolCallId,
    tool: event.toolName,
    error: event.isError,
    latencyMs: Math.round(performance.now() - (starts.get(event.toolCallId) ?? performance.now())),
    outputBytes: Buffer.byteLength(JSON.stringify(event.result)),
  }));
  pi.on("message_end", (event) => {
    if (event.message.role === "assistant") emit("MODEL_MESSAGE", {
      stopReason: event.message.stopReason,
      usage: event.message.usage,
      fullLatencyMs: Math.round(performance.now() - requestStarted),
    });
  });
  pi.on("agent_settled", () => emit("AGENT_SETTLED", {}));
}
