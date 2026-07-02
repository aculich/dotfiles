#!/usr/bin/env node
/**
 * Scan a project for lock files, manifests, and config signals.
 * Outputs a stack profile JSON to stdout or --out file.
 *
 * Usage: node scan-stack.mjs [projectRoot] [--out profile.json]
 */
import fs from "node:fs";
import path from "node:path";
import {
  parseArgs,
  walkFiles,
  extractPackages,
  inferTags,
  resolveProviders,
  loadMapping,
  skillRootFromImportMeta,
  LOCK_MANIFEST_FILES,
  CONFIG_FILES,
} from "./lib.mjs";

const args = parseArgs(process.argv);
const projectRoot = path.resolve(args._[0] || process.cwd());
const skillRoot = skillRootFromImportMeta(import.meta.url);
const mapping = loadMapping(skillRoot);

const allFiles = walkFiles(projectRoot);
const lockFiles = [];
const configHits = [];
const configProviders = [];
const ecosystems = new Set();
const packages = new Set();

for (const file of allFiles) {
  const rel = path.relative(projectRoot, file);
  const base = path.basename(file);

  if (LOCK_MANIFEST_FILES.has(base)) {
    lockFiles.push(rel);
    ecosystems.add(ecosystemFor(base));
    try {
      const content = fs.readFileSync(file, "utf8");
      for (const pkg of extractPackages(file, content)) packages.add(pkg);
    } catch {
      /* ignore unreadable */
    }
  }

  if (CONFIG_FILES.includes(base)) {
    configHits.push(rel);
    const provider = mapping.config?.[base];
    if (provider) configProviders.push(provider);
  }

  if (rel.startsWith(".github/workflows/") && (rel.endsWith(".yml") || rel.endsWith(".yaml"))) {
    configHits.push(rel);
  }
  if (rel.includes("terraform/") && rel.endsWith(".tf")) {
    configHits.push(rel);
  }
}

const providers = resolveProviders(packages, mapping, configProviders);
const tags = inferTags(packages);

const summaryParts = [];
if (ecosystems.size) summaryParts.push([...ecosystems].join(", "));
if (providers.length) summaryParts.push(`vendors: ${providers.slice(0, 8).join(", ")}`);
if (tags.length) summaryParts.push(`tags: ${tags.slice(0, 6).join(", ")}`);

const profile = {
  scanned_at: new Date().toISOString(),
  project_root: projectRoot,
  lock_files: lockFiles.sort(),
  config_files: configHits.sort(),
  ecosystems: [...ecosystems].sort(),
  packages: [...packages].sort(),
  providers,
  tags,
  summary: summaryParts.join(" · ") || "No lock files detected",
};

const out = JSON.stringify(profile, null, 2);
if (args.out) {
  fs.writeFileSync(args.out, out + "\n");
  console.error(`Wrote stack profile to ${args.out}`);
} else {
  console.log(out);
}

function ecosystemFor(base) {
  if (["package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lock", "bun.lockb", "package.json"].includes(base))
    return "Node.js";
  if (["Cargo.lock", "Cargo.toml"].includes(base)) return "Rust";
  if (["poetry.lock", "uv.lock", "Pipfile.lock", "pyproject.toml", "requirements.txt"].includes(base))
    return "Python";
  if (["Gemfile.lock", "Gemfile"].includes(base)) return "Ruby";
  if (["composer.lock", "composer.json"].includes(base)) return "PHP";
  if (["go.sum", "go.mod"].includes(base)) return "Go";
  if (["mix.lock"].includes(base)) return "Elixir";
  if (["pubspec.lock", "pubspec.yaml"].includes(base)) return "Dart";
  if (["Package.resolved"].includes(base)) return "Swift";
  if (["packages.lock.json"].includes(base)) return ".NET";
  return "Unknown";
}
