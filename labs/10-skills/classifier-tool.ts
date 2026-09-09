import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
export default function classifier(pi: ExtensionAPI): void {
  pi.registerTool({
    name: "classify_evidence",
    label: "Classify Evidence",
    description: "Classify a claim from whether its required file exists.",
    parameters: Type.Object({ fileExists: Type.Boolean() }),
    async execute(_id, params) { return { content: [{ type: "text", text: params.fileExists ? "SUPPORTED" : "UNSUPPORTED" }], details: { fileExists: params.fileExists } }; },
  });
}
