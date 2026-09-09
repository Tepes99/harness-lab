import { appendFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type TraceRecord = {
  timestamp: string;
  event: string;
  data: unknown;
};

export default function requestRecorder(pi: ExtensionAPI): void {
  const configuredPath = process.env.HARNESS_LAB_TRACE_FILE;
  const tracePath = resolve(
    configuredPath ?? ".lab-output/lab-01/manual.trace.jsonl",
  );

  mkdirSync(dirname(tracePath), { recursive: true });

  const record = (event: string, data: unknown): void => {
    const entry: TraceRecord = {
      timestamp: new Date().toISOString(),
      event,
      data,
    };
    appendFileSync(tracePath, `${JSON.stringify(entry)}\n`, "utf8");
  };

  pi.on("session_start", (event, ctx) => {
    record("session_start", {
      reason: event.reason,
      sessionFile: ctx.sessionManager.getSessionFile() ?? null,
      cwd: ctx.cwd,
    });
  });

  pi.on("before_agent_start", (event) => {
    record("before_agent_start", {
      prompt: event.prompt,
      systemPrompt: event.systemPrompt,
      systemPromptOptions: event.systemPromptOptions,
    });
  });

  pi.on("agent_start", () => record("agent_start", {}));

  pi.on("turn_start", (event) => {
    record("turn_start", {
      turnIndex: event.turnIndex,
      timestamp: event.timestamp,
    });
  });

  pi.on("context", (event) => {
    record("context", { messages: event.messages });
  });

  pi.on("before_provider_request", (event) => {
    record("before_provider_request", { payload: event.payload });
  });

  pi.on("after_provider_response", (event) => {
    record("after_provider_response", { status: event.status });
  });

  pi.on("message_end", (event) => {
    record("message_end", { message: event.message });
  });

  pi.on("turn_end", (event) => {
    record("turn_end", {
      turnIndex: event.turnIndex,
      message: event.message,
      toolResults: event.toolResults,
    });
  });

  pi.on("agent_end", (event) => {
    record("agent_end", { messages: event.messages });
  });

  pi.on("agent_settled", () => record("agent_settled", {}));
}

