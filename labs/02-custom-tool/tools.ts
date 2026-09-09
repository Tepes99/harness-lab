import { readdir, realpath } from "node:fs/promises";
import { extname, relative, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

interface Inventory {
  root: string;
  fileCount: number;
  directoryCount: number;
  extensions: Record<string, number>;
  truncated: boolean;
}

const MAX_ENTRIES = 5_000;

async function assertInsideWorkspace(cwd: string, requestedPath: string): Promise<string> {
  const normalized = requestedPath.startsWith("@")
    ? requestedPath.slice(1)
    : requestedPath;
  const [workspaceRoot, target] = await Promise.all([
    realpath(cwd),
    realpath(resolve(cwd, normalized)),
  ]);
  const fromWorkspace = relative(workspaceRoot, target);

  if (fromWorkspace === ".." || fromWorkspace.startsWith(`..${process.platform === "win32" ? "\\" : "/"}`)) {
    throw new Error(`Path must stay inside the workspace: ${requestedPath}`);
  }
  return target;
}

async function inventoryWorkspace(
  root: string,
  maxDepth: number,
  signal?: AbortSignal,
): Promise<Inventory> {
  const inventory: Inventory = {
    root,
    fileCount: 0,
    directoryCount: 0,
    extensions: {},
    truncated: false,
  };

  const visit = async (directory: string, depth: number): Promise<void> => {
    if (signal?.aborted) {
      throw signal.reason ?? new Error("Workspace inventory cancelled");
    }

    const entries = await readdir(directory, { withFileTypes: true });
    for (const entry of entries.sort((a, b) => a.name.localeCompare(b.name))) {
      if (inventory.fileCount + inventory.directoryCount >= MAX_ENTRIES) {
        inventory.truncated = true;
        return;
      }

      if (entry.isDirectory()) {
        inventory.directoryCount += 1;
        if (depth < maxDepth && entry.name !== "node_modules" && entry.name !== ".git") {
          await visit(resolve(directory, entry.name), depth + 1);
        }
      } else if (entry.isFile()) {
        inventory.fileCount += 1;
        const extension = extname(entry.name) || "[no extension]";
        inventory.extensions[extension] = (inventory.extensions[extension] ?? 0) + 1;
      }
    }
  };

  await visit(root, 0);
  return inventory;
}

export default function customTools(pi: ExtensionAPI): void {
  pi.registerTool({
    name: "structured_echo",
    label: "Structured Echo",
    description: "Echo a non-empty message one to three times as structured JSON.",
    promptSnippet: "Echo a validated message as structured JSON",
    parameters: Type.Object(
      {
        message: Type.String({ minLength: 1 }),
        repeat: Type.Optional(Type.Integer({ minimum: 1, maximum: 3 })),
      },
      { additionalProperties: false },
    ),
    async execute(_toolCallId, params) {
      const result = {
        original: params.message,
        echoed: Array.from({ length: params.repeat ?? 1 }, () => params.message),
      };
      return {
        content: [{ type: "text", text: JSON.stringify(result) }],
        details: result,
      };
    },
  });

  pi.registerTool({
    name: "workspace_inventory",
    label: "Workspace Inventory",
    description: "Count files, directories, and file extensions under a workspace-relative path without reading file contents.",
    promptSnippet: "Summarize the workspace tree without reading file contents",
    parameters: Type.Object(
      {
        path: Type.Optional(Type.String({ minLength: 1, description: "Workspace-relative path; defaults to ." })),
        maxDepth: Type.Optional(Type.Integer({ minimum: 0, maximum: 3 })),
      },
      { additionalProperties: false },
    ),
    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      const target = await assertInsideWorkspace(ctx.cwd, params.path ?? ".");
      const result = await inventoryWorkspace(target, params.maxDepth ?? 2, signal);
      const display = {
        ...result,
        root: relative(ctx.cwd, result.root) || ".",
        extensions: Object.fromEntries(
          Object.entries(result.extensions).sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0])),
        ),
      };
      return {
        content: [{ type: "text", text: JSON.stringify(display, null, 2) }],
        details: display,
      };
    },
  });
}
