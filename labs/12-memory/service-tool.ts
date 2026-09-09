import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
export default function serviceMemory(pi: ExtensionAPI): void {
  const base = process.env.HARNESS_MEMORY_SERVICE ?? "http://127.0.0.1:18765";
  pi.registerTool({ name: "service_memory", label: "Service Memory", description: "Put or get durable memory through an external Python service.", parameters: Type.Object({ action: StringEnum(["put", "get"] as const), key: Type.String(), value: Type.Optional(Type.String()) }), async execute(_id, p, signal) {
    if (p.action === "put") { if (p.value === undefined) throw new Error("value required"); await fetch(`${base}/memory`, { method: "POST", body: JSON.stringify({ key: p.key, value: p.value }), headers: { "content-type": "application/json" }, signal }); }
    const response = await fetch(`${base}/memory/${encodeURIComponent(p.key)}`, { signal }); const data = await response.json() as { value: string | null };
    return { content: [{ type: "text", text: data.value ?? "NOT_FOUND" }], details: { key: p.key, found: data.value !== null } };
  }});
}
