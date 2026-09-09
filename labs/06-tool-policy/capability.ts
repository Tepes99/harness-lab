import { mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function markerCapability(pi: ExtensionAPI): void {
  pi.registerTool({
    name: "lab_write_marker",
    label: "Write Lab Marker",
    description: "Write a short marker to the experiment-controlled output path.",
    parameters: Type.Object({ content: Type.String({ minLength: 1, maxLength: 100 }) }, { additionalProperties: false }),
    async execute(_id, params) {
      const target = resolve(process.env.HARNESS_LAB_POLICY_MARKER ?? ".lab-output/lab-06/marker.txt");
      await mkdir(dirname(target), { recursive: true });
      await writeFile(target, `${params.content}\n`, "utf8");
      return { content: [{ type: "text", text: `Wrote marker: ${params.content}` }], details: { target } };
    },
  });
}
