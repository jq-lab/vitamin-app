import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const appRoot = path.resolve(__dirname, "..");
const pnpmRoot = path.join(appRoot, "node_modules", ".pnpm");

async function exists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

async function listSwiftFiles(dir) {
  const out = [];
  const entries = await fs.readdir(dir, { withFileTypes: true });
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      out.push(...(await listSwiftFiles(full)));
    } else if (entry.isFile() && entry.name.endsWith(".swift")) {
      out.push(full);
    }
  }
  return out;
}

async function main() {
  if (!(await exists(pnpmRoot))) {
    return;
  }

  const entries = await fs.readdir(pnpmRoot);
  const packageDirName = entries.find((name) => name.startsWith("expo-modules-jsi@"));
  if (!packageDirName) {
    return;
  }

  const sourceRoot = path.join(pnpmRoot, packageDirName, "node_modules", "expo-modules-jsi", "apple", "Sources");
  if (!(await exists(sourceRoot))) {
    return;
  }

  let changed = 0;
  for (const filePath of await listSwiftFiles(sourceRoot)) {
    const before = await fs.readFile(filePath, "utf8");
    let after = before
      .replaceAll("weak let runtime", "weak var runtime")
      .replaceAll("  weak var runtime", "  nonisolated(unsafe) weak var runtime")
      .replaceAll("  private weak var runtime", "  nonisolated(unsafe) private weak var runtime")
      .replaceAll("  internal weak var runtime", "  nonisolated(unsafe) internal weak var runtime")
      .replaceAll("nonisolated(unsafe) nonisolated(unsafe)", "nonisolated(unsafe)");

    if (after !== before) {
      await fs.writeFile(filePath, after);
      changed += 1;
    }
  }

  if (changed > 0) {
    console.log(`Patched expo-modules-jsi Swift runtime references in ${changed} file(s).`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
