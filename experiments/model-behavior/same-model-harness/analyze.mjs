import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
const output = process.argv[2];
const suite = JSON.parse(readFileSync(process.argv[3], "utf8"));
const configurations = ["minimal-pi", "coding", "verification", "planner-executor", "actor-verifier", "multi-agent"];
const observations = suite.tasks.flatMap((task) => configurations.map((configuration) => {
  const events = readFileSync(join(output, `${task.id}--${configuration}.events.jsonl`), "utf8").trim().split("\n").filter(Boolean).map(JSON.parse);
  const assistant = events.filter((event) => event.type === "message_end" && event.message?.role === "assistant");
  const finalText = assistant.flatMap((event) => event.message.content ?? []).filter((part) => part.type === "text").at(-1)?.text ?? "";
  const toolEnds = events.filter((event) => event.type === "tool_execution_end");
  const verificationPassed = toolEnds.some((event) => !event.isError && event.result?.details?.verified === true);
  const evidenceObserved = toolEnds.some((event) => !event.isError && (
    event.toolName === "read" ||
    event.result?.details?.verified === true ||
    event.result?.details?.childReadObserved === true
  ));
  const completion = finalText.includes(task.expected) || verificationPassed;
  const failedToolCalls = toolEnds.filter((event) => event.isError).length;
  return {
    task: task.id, configuration, completed: Number(completion),
    toolCalls: toolEnds.length,
    failedToolCalls,
    unsupportedSuccessClaims: Number(completion && !evidenceObserved),
    latencyMs: Number(readFileSync(join(output, `${task.id}--${configuration}.duration-ms`), "utf8")),
    generatedTokens: assistant.reduce((sum, event) => sum + (event.message.usage?.output ?? 0), 0),
    contextTokens: assistant.reduce((sum, event) => sum + (event.message.usage?.input ?? 0), 0),
    humanInterventions: 0,
    recoveredAfterToolFailure: Number(failedToolCalls > 0 && completion),
    evidenceObserved,
    finalText
  };
}));
const rows = configurations.map((configuration) => {
  const values = observations.filter((observation) => observation.configuration === configuration);
  const sum = (key) => values.reduce((total, value) => total + value[key], 0);
  const completed = sum("completed");
  return { configuration, tasks: values.length, completed, completionRate: completed / values.length, toolCalls: sum("toolCalls"), failedToolCalls: sum("failedToolCalls"), unsupportedSuccessClaims: sum("unsupportedSuccessClaims"), latencyMs: sum("latencyMs"), generatedTokens: sum("generatedTokens"), contextTokens: sum("contextTokens"), humanInterventions: sum("humanInterventions"), recoveredAfterToolFailure: sum("recoveredAfterToolFailure") };
});
writeFileSync(join(output, "results.json"), `${JSON.stringify({ suite: suite.suite, provider: "home-vllm", model: "qwen3.8-27b-fp8", rows, observations }, null, 2)}\n`);
const header = "| Configuration | Complete | Tools | Failed | Unsupported | Total latency ms | Output tok | Context tok | Human | Recoveries |\n|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|";
const table = rows.map((row) => `| ${row.configuration} | ${row.completed}/${row.tasks} | ${row.toolCalls} | ${row.failedToolCalls} | ${row.unsupportedSuccessClaims} | ${row.latencyMs} | ${row.generatedTokens} | ${row.contextTokens} | ${row.humanInterventions} | ${row.recoveredAfterToolFailure} |`).join("\n");
writeFileSync(join(output, "REPORT.md"), `# Same model, different harness\n\nProvider: \`home-vllm\`; model: \`qwen3.8-27b-fp8\`; suite: \`${suite.suite}\`.\n\n${header}\n${table}\n\nAn unsupported success is a correct-looking final answer without a successful evidence-bearing tool event. Recovery means a task completed after at least one failed tool call. Totals cover ${suite.tasks.length} tasks.\n`);
console.log(table);
