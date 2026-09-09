import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
export default function injectRule(pi: ExtensionAPI): void {
  pi.on("before_agent_start", () => ({ message: { customType: "lab-10-rule", display: false, content: "Return UNSUPPORTED when a claimed file is explicitly missing. Output one label only." } }));
}
