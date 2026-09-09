import { appendFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface LifecycleRecord {
  sequence: number;
  timestamp: string;
  event: string;
  summary: Record<string, unknown>;
}

export default function lifecycleTrace(pi: ExtensionAPI): void {
  const outputPath = resolve(
    process.env.HARNESS_LAB_LIFECYCLE_FILE ??
      ".lab-output/lifecycle/manual.lifecycle.jsonl",
  );
  mkdirSync(dirname(outputPath), { recursive: true });
  let sequence = 0;

  const record = (event: string, summary: Record<string, unknown> = {}): void => {
    const entry: LifecycleRecord = {
      sequence: ++sequence,
      timestamp: new Date().toISOString(),
      event,
      summary,
    };
    appendFileSync(outputPath, `${JSON.stringify(entry)}\n`, "utf8");
  };

  pi.on("session_start", (event, ctx) => {
    record("session_start", {
      reason: event.reason,
      persisted: ctx.sessionManager.getSessionFile() !== undefined,
    });
  });
  pi.on("before_agent_start", (event) => {
    record("before_agent_start", {
      promptCharacters: event.prompt.length,
      systemPromptCharacters: event.systemPrompt.length,
      activeTools: event.systemPromptOptions.selectedTools,
    });
  });
  pi.on("agent_start", () => record("agent_start"));
  pi.on("turn_start", (event) => record("turn_start", { turnIndex: event.turnIndex }));
  pi.on("context", (event) => {
    record("context", {
      messageCount: event.messages.length,
      roles: event.messages.map((message) => message.role),
    });
  });
  pi.on("before_provider_request", () => record("before_provider_request"));
  pi.on("after_provider_response", (event) => {
    record("after_provider_response", { status: event.status });
  });
  pi.on("message_start", (event) => {
    record("message_start", { role: event.message.role });
  });
  pi.on("message_end", (event) => {
    const message = event.message;
    record("message_end", {
      role: message.role,
      ...(message.role === "assistant" ? { stopReason: message.stopReason } : {}),
      ...(message.role === "toolResult"
        ? { toolName: message.toolName, isError: message.isError }
        : {}),
    });
  });
  pi.on("tool_execution_start", (event) => {
    record("tool_execution_start", {
      toolCallId: event.toolCallId,
      toolName: event.toolName,
    });
  });
  pi.on("tool_call", (event) => {
    record("tool_call", {
      toolCallId: event.toolCallId,
      toolName: event.toolName,
    });
  });
  pi.on("tool_result", (event) => {
    record("tool_result", {
      toolCallId: event.toolCallId,
      toolName: event.toolName,
      isError: event.isError,
    });
  });
  pi.on("tool_execution_end", (event) => {
    record("tool_execution_end", {
      toolCallId: event.toolCallId,
      toolName: event.toolName,
      isError: event.isError,
    });
  });
  pi.on("turn_end", (event) => {
    record("turn_end", {
      turnIndex: event.turnIndex,
      toolResultCount: event.toolResults.length,
    });
  });
  pi.on("agent_end", (event) => {
    record("agent_end", { messageCount: event.messages.length });
  });
  pi.on("agent_settled", () => record("agent_settled"));
  pi.on("session_shutdown", (event) => {
    record("session_shutdown", { reason: event.reason });
  });
}
