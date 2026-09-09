import { appendFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface ContextRecord {
  timestamp: string;
  stage: string;
  data: unknown;
}

function serializedCharacters(value: unknown): number {
  return JSON.stringify(value).length;
}

export default function contextInspector(pi: ExtensionAPI): void {
  const outputPath = resolve(
    process.env.HARNESS_LAB_CONTEXT_FILE ??
      ".lab-output/context/manual.context.jsonl",
  );
  mkdirSync(dirname(outputPath), { recursive: true });

  const record = (stage: string, data: unknown): void => {
    const entry: ContextRecord = {
      timestamp: new Date().toISOString(),
      stage,
      data,
    };
    appendFileSync(outputPath, `${JSON.stringify(entry)}\n`, "utf8");
  };

  pi.on("before_agent_start", (event) => {
    const options = event.systemPromptOptions;
    record("system_prompt", {
      prompt: event.prompt,
      finalSystemPrompt: event.systemPrompt,
      finalSystemPromptCharacters: event.systemPrompt.length,
      approximateSystemPromptTokens: Math.ceil(event.systemPrompt.length / 4),
      sources: {
        customPrompt: options.customPrompt ?? null,
        appendSystemPrompt: options.appendSystemPrompt ?? null,
        cwd: options.cwd,
        selectedTools: options.selectedTools ?? [],
        toolSnippets: options.toolSnippets ?? {},
        promptGuidelines: options.promptGuidelines ?? [],
        contextFiles: options.contextFiles ?? [],
        skills: (options.skills ?? []).map((skill) => ({
          name: skill.name,
          description: skill.description,
          filePath: skill.filePath,
          disableModelInvocation: skill.disableModelInvocation,
        })),
      },
    });
  });

  pi.on("context", (event) => {
    record("pi_context", {
      messages: event.messages,
      messageCount: event.messages.length,
      serializedCharacters: serializedCharacters(event.messages),
      approximateTokens: Math.ceil(serializedCharacters(event.messages) / 4),
      messagesBySource: event.messages.map((message, index) => ({
        index,
        role: message.role,
        source:
          message.role === "custom"
            ? `extension:${message.customType}`
            : `session-or-current-${message.role}`,
        serializedCharacters: serializedCharacters(message),
      })),
    });
  });

  pi.on("before_provider_request", (event) => {
    record("provider_payload", {
      payload: event.payload,
      serializedCharacters: serializedCharacters(event.payload),
      approximateTokens: Math.ceil(serializedCharacters(event.payload) / 4),
    });
  });

  pi.on("message_end", (event) => {
    if (event.message.role !== "assistant") return;
    record("assistant_usage", {
      stopReason: event.message.stopReason,
      usage: event.message.usage,
    });
  });
}
