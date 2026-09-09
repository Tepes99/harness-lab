import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function injectContext(pi: ExtensionAPI): void {
  const marker = process.env.HARNESS_LAB_CONTEXT_MARKER ?? "INJECTION_SEEN";

  pi.on("before_agent_start", () => ({
    message: {
      customType: "lab-05-temporary-context",
      content: `Temporary experiment context: reply with exactly ${marker}.`,
      display: false,
      details: {
        source: "labs/05-context/inject-context.ts",
        temporary: true,
      },
    },
  }));
}
