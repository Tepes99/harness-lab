import { DatabaseSync } from "node:sqlite";
import { resolve } from "node:path";
import { StringEnum } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
export default function sqliteMemory(pi: ExtensionAPI): void {
  const db = new DatabaseSync(resolve(process.env.HARNESS_LOCAL_MEMORY_DB ?? ".lab-output/local-memory.sqlite"));
  db.exec("CREATE TABLE IF NOT EXISTS memory (key TEXT PRIMARY KEY, value TEXT NOT NULL)");
  pi.on("session_shutdown", () => db.close());
  pi.registerTool({ name: "local_memory", label: "Local Memory", description: "Put or get a durable key-value memory in extension-owned SQLite.", parameters: Type.Object({ action: StringEnum(["put", "get"] as const), key: Type.String(), value: Type.Optional(Type.String()) }), async execute(_id, p) {
    if (p.action === "put") { if (p.value === undefined) throw new Error("value required"); db.prepare("INSERT INTO memory(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value").run(p.key, p.value); }
    const row = db.prepare("SELECT value FROM memory WHERE key=?").get(p.key) as { value: string } | undefined;
    return { content: [{ type: "text", text: row?.value ?? "NOT_FOUND" }], details: { key: p.key, found: row !== undefined } };
  }});
}
