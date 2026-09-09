import { appendFileSync, mkdirSync, readFileSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

type ReceiptType = "TASK_CLAIMED_COMPLETE" | "FILE_OBSERVED" | "VERIFICATION_PASSED" | "VERIFICATION_FAILED";
export interface Receipt { timestamp: string; type: ReceiptType; subject: string; evidence: Record<string, unknown>; }

export default function completionVerifier(pi: ExtensionAPI): void {
  const receiptPath = resolve(process.env.HARNESS_RECEIPTS_FILE ?? ".lab-output/receipts/manual.jsonl");
  mkdirSync(dirname(receiptPath), { recursive: true });
  const emit = (type: ReceiptType, subject: string, evidence: Record<string, unknown>) =>
    appendFileSync(receiptPath, `${JSON.stringify({ timestamp: new Date().toISOString(), type, subject, evidence } satisfies Receipt)}\n`);

  pi.registerTool({
    name: "submit_completion",
    label: "Submit Completion",
    description: "Claim completion and verify that a workspace-relative file exists with optional exact content.",
    parameters: Type.Object({ path: Type.String({ minLength: 1 }), expectedContent: Type.Optional(Type.String()) }, { additionalProperties: false }),
    async execute(_id, params, _signal, _update, ctx) {
      emit("TASK_CLAIMED_COMPLETE", params.path, { expectedContent: params.expectedContent ?? null });
      const target = resolve(ctx.cwd, params.path);
      const rel = relative(resolve(ctx.cwd), target);
      if (rel === ".." || rel.startsWith("../")) throw new Error("Verification path must stay inside workspace");
      try {
        const content = readFileSync(target, "utf8");
        emit("FILE_OBSERVED", params.path, { exists: true, bytes: Buffer.byteLength(content) });
        if (params.expectedContent !== undefined && content !== params.expectedContent) {
          emit("VERIFICATION_FAILED", params.path, { reason: "content_mismatch" });
          throw new Error(`Completion unsupported: ${params.path} content did not match`);
        }
        emit("VERIFICATION_PASSED", params.path, { exists: true, contentMatched: params.expectedContent !== undefined });
        return { content: [{ type: "text", text: `VERIFIED: ${params.path}` }], details: { verified: true, path: params.path }, terminate: true };
      } catch (error: unknown) {
        if ((error as NodeJS.ErrnoException).code === "ENOENT") emit("VERIFICATION_FAILED", params.path, { reason: "missing_file" });
        throw error;
      }
    },
  });
}
