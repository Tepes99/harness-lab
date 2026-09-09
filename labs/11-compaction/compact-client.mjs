import { spawn } from "node:child_process";
import { appendFileSync } from "node:fs";
const [sessionId, sessionDir, extension, output] = process.argv.slice(2);
const proc = spawn("pi", ["--mode", "rpc", "--provider", "home-vllm", "--model", "qwen3.8-27b-fp8", "--thinking", "off", "--session-id", sessionId, "--session-dir", sessionDir, "--approve", "--no-extensions", "-e", extension, "--no-skills", "--no-prompt-templates", "--no-themes", "--no-context-files"], { stdio: ["pipe", "pipe", "inherit"] });
let buffered = "";
proc.stdout.on("data", (chunk) => {
  buffered += chunk.toString("utf8");
  while (buffered.includes("\n")) {
    const index = buffered.indexOf("\n");
    const line = buffered.slice(0, index);
    buffered = buffered.slice(index + 1);
    if (!line) continue;
    appendFileSync(output, `${line}\n`);
    const value = JSON.parse(line);
    if (value.type === "response" && value.command === "compact") proc.kill("SIGTERM");
  }
});
proc.stdin.write(`${JSON.stringify({ id: "compact-1", type: "compact", customInstructions: "Preserve the codeword ORBIT-731 and unresolved requirement: retain receipts." })}\n`);
await new Promise((resolve, reject) => { proc.on("close", resolve); proc.on("error", reject); });
