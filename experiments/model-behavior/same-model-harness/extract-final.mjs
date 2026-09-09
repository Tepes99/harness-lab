import { readFileSync } from "node:fs";
const events = readFileSync(process.argv[2], "utf8").trim().split("\n").filter(Boolean).map(JSON.parse);
const messages = events.filter((event) => event.type === "message_end" && event.message?.role === "assistant");
const text = messages.flatMap((event) => event.message.content ?? []).filter((part) => part.type === "text").at(-1)?.text ?? "";
process.stdout.write(text);
