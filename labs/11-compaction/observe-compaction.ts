import { appendFileSync } from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
export default function observe(pi: ExtensionAPI): void {
  const path = process.env.HARNESS_COMPACTION_TRACE;
  if (!path) return;
  pi.on("session_before_compact", (event) => appendFileSync(path, `${JSON.stringify({ event: "before", reason: event.reason, tokensBefore: event.preparation.tokensBefore, summarize: event.preparation.messagesToSummarize.length, firstKeptEntryId: event.preparation.firstKeptEntryId, settings: event.preparation.settings })}\n`));
  pi.on("session_compact", (event) => appendFileSync(path, `${JSON.stringify({ event: "complete", reason: event.reason, fromExtension: event.fromExtension, summary: event.compactionEntry.summary })}\n`));
  pi.on("session_compact_failed", (event) => appendFileSync(path, `${JSON.stringify({ event: "failed", reason: event.reason, error: event.errorMessage })}\n`));
}
