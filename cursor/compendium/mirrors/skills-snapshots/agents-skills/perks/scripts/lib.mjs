import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const SKIP_DIRS = new Set([
  "node_modules",
  ".git",
  "vendor",
  "dist",
  "build",
  ".next",
  ".astro",
  "target",
  "__pycache__",
  ".venv",
  "venv",
  ".turbo",
  ".cache",
  "coverage",
]);

export const LOCK_MANIFEST_FILES = new Set([
  "package-lock.json",
  "yarn.lock",
  "pnpm-lock.yaml",
  "bun.lock",
  "bun.lockb",
  "Cargo.lock",
  "poetry.lock",
  "uv.lock",
  "Pipfile.lock",
  "Gemfile.lock",
  "composer.lock",
  "go.sum",
  "go.mod",
  "mix.lock",
  "pubspec.lock",
  "Package.resolved",
  "packages.lock.json",
  "package.json",
  "pyproject.toml",
  "requirements.txt",
  "Cargo.toml",
  "Gemfile",
  "composer.json",
  "pubspec.yaml",
]);

export const CONFIG_FILES = [
  "vercel.json",
  "netlify.toml",
  "firebase.json",
  "serverless.yml",
  "fly.toml",
  "railway.json",
];

export function parseArgs(argv) {
  const args = { _: [] };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--")) {
      const key = a.slice(2);
      const next = argv[i + 1];
      if (next && !next.startsWith("--")) {
        args[key] = next;
        i++;
      } else {
        args[key] = true;
      }
    } else {
      args._.push(a);
    }
  }
  return args;
}

export function walkFiles(root, maxDepth = 6) {
  const found = [];
  function walk(dir, depth) {
    if (depth > maxDepth) return;
    let entries;
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const ent of entries) {
      if (ent.name.startsWith(".") && ent.name !== ".github") continue;
      const full = path.join(dir, ent.name);
      if (ent.isDirectory()) {
        if (SKIP_DIRS.has(ent.name)) continue;
        walk(full, depth + 1);
      } else if (ent.isFile()) {
        found.push(full);
      }
    }
  }
  walk(root, 0);
  return found;
}

export function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

export function normalizePackageName(name) {
  return name.trim().toLowerCase();
}

/** Extract package names from various lock/manifest formats. */
export function extractPackages(filePath, content) {
  const base = path.basename(filePath);
  const names = new Set();

  if (base === "package.json") {
    try {
      const pkg = JSON.parse(content);
      for (const field of [
        "dependencies",
        "devDependencies",
        "peerDependencies",
        "optionalDependencies",
      ]) {
        if (pkg[field]) {
          for (const n of Object.keys(pkg[field])) names.add(normalizePackageName(n));
        }
      }
    } catch {
      /* ignore */
    }
    return names;
  }

  if (base === "bun.lock" || base === "bun.lockb") {
    try {
      const lock = JSON.parse(content);
      if (lock.packages) {
        for (const key of Object.keys(lock.packages)) {
          const pkgName = key.split("@").length > 2 ? "@" + key.split("@").slice(1, -1).join("@") : key.split("@")[0];
          if (pkgName) names.add(normalizePackageName(pkgName));
        }
      }
      if (lock.workspaces) {
        for (const ws of Object.values(lock.workspaces)) {
          for (const field of ["dependencies", "devDependencies"]) {
            if (ws[field]) {
              for (const n of Object.keys(ws[field])) names.add(normalizePackageName(n));
            }
          }
        }
      }
    } catch {
      /* ignore */
    }
    return names;
  }

  if (base === "package-lock.json") {
    try {
      const lock = JSON.parse(content);
      if (lock.packages) {
        for (const key of Object.keys(lock.packages)) {
          if (key === "") continue;
          const pkgName = key.startsWith("node_modules/")
            ? key.replace(/^node_modules\//, "").split("node_modules/").pop()
            : key;
          if (pkgName) names.add(normalizePackageName(pkgName));
        }
      }
      if (lock.dependencies) {
        for (const n of Object.keys(lock.dependencies)) names.add(normalizePackageName(n));
      }
    } catch {
      /* ignore */
    }
    return names;
  }

  if (base === "pnpm-lock.yaml") {
    for (const m of content.matchAll(/^\s{2}\/(@?[^@\n]+)/gm)) {
      const raw = m[1].replace(/^\/+/, "");
      if (raw && !raw.startsWith("(")) names.add(normalizePackageName(raw));
    }
    return names;
  }

  if (base === "yarn.lock") {
    for (const block of content.split("\n\n")) {
      const first = block.split("\n")[0]?.replace(/"/g, "").trim();
      if (first && !first.startsWith("#")) {
        const pkg = first.split("@")[0];
        if (pkg) names.add(normalizePackageName(pkg));
      }
    }
    return names;
  }

  if (base === "Cargo.toml") {
    for (const m of content.matchAll(/^(\w[\w-]*)\s*=\s/m)) {
      names.add(normalizePackageName(m[1]));
    }
    return names;
  }

  if (base === "Cargo.lock") {
    for (const m of content.matchAll(/^name = "([^"]+)"/gm)) {
      names.add(normalizePackageName(m[1]));
    }
    return names;
  }

  if (base === "go.mod") {
    for (const m of content.matchAll(/^\s+([\w./-]+)\s+v[\d.]/gm)) {
      const mod = m[1].split("/").pop();
      if (mod) names.add(normalizePackageName(mod));
    }
    return names;
  }

  if (base === "requirements.txt" || base === "pyproject.toml") {
    for (const m of content.matchAll(/^([a-zA-Z0-9_.-]+)/gm)) {
      const n = m[1].toLowerCase();
      if (!["import", "from", "version", "requires", "python", "build"].includes(n)) {
        names.add(n);
      }
    }
    return names;
  }

  if (base === "Gemfile" || base === "Gemfile.lock") {
    for (const m of content.matchAll(/(?:gem|spec\.name)\s+["']([^"']+)["']/g)) {
      names.add(normalizePackageName(m[1]));
    }
    return names;
  }

  if (base === "composer.json" || base === "composer.lock") {
    for (const m of content.matchAll(/"name"\s*:\s*"([^"]+)"/g)) {
      const parts = m[1].split("/");
      names.add(normalizePackageName(parts[parts.length - 1]));
    }
    return names;
  }

  return names;
}

const TAG_RULES = [
  { pattern: /^(next|nuxt|remix|astro|sveltekit|gatsby)$/, tags: ["dev tools", "cloud"] },
  { pattern: /^(react|vue|svelte|angular|solid-js)$/, tags: ["dev tools"] },
  { pattern: /^@aws-sdk|^aws-sdk|^serverless$/, tags: ["cloud"] },
  { pattern: /^@google-cloud|^firebase|^@google\//, tags: ["cloud", "ai"] },
  { pattern: /^@azure/, tags: ["cloud"] },
  { pattern: /^openai|^@openai|^@anthropic|^langchain|^@langchain/, tags: ["ai", "llm"] },
  { pattern: /^@sentry|^posthog|^@datadog|^amplitude|^mixpanel/, tags: ["dev tools"] },
  { pattern: /^stripe|^@stripe/, tags: ["fintech"] },
  { pattern: /^@temporalio/, tags: ["automation", "dev tools"] },
  { pattern: /^hardhat|^ethers|^web3|^@alchemy/, tags: ["web3"] },
  { pattern: /^@pulumi|^terraform/, tags: ["iac", "devops"] },
  { pattern: /^prisma|^drizzle|^typeorm/, tags: ["data", "dev tools"] },
  { pattern: /^@pinecone|^algolia/, tags: ["ai", "search"] },
  { pattern: /^django|^fastapi|^flask/, tags: ["dev tools", "api"] },
  { pattern: /^rails$/, tags: ["dev tools"] },
];

export function inferTags(packages) {
  const tags = new Set();
  for (const pkg of packages) {
    for (const rule of TAG_RULES) {
      if (rule.pattern.test(pkg)) {
        for (const t of rule.tags) tags.add(t);
      }
    }
  }
  return [...tags];
}

export function resolveProviders(packages, mapping, configHits = []) {
  const providers = new Set(configHits);
  const packageList = [...packages];

  for (const pkg of packageList) {
    if (mapping.packages[pkg]) {
      providers.add(mapping.packages[pkg]);
      continue;
    }
    for (const [prefix, slug] of Object.entries(mapping.packages)) {
      if (prefix.includes("/") || prefix.includes("*")) continue;
      if (pkg === prefix || pkg.startsWith(prefix + "/")) {
        providers.add(slug);
        break;
      }
      if (prefix.startsWith("@") && pkg.startsWith(prefix)) {
        providers.add(slug);
        break;
      }
    }
  }
  return [...providers];
}

export function loadMapping(skillRoot) {
  const mappingPath = path.join(skillRoot, "reference/dependency-mapping.json");
  return loadJson(mappingPath);
}

export function skillRootFromImportMeta(importMetaUrl) {
  return path.resolve(path.dirname(fileURLToPath(importMetaUrl)), "..");
}

export const PERSONAS = [
  "startup",
  "student",
  "oss",
  "indie",
  "ambassador",
  "nonprofit",
];

export const PERKS_JSON_URL = "https://makerperks.com/perks.json";
export const MAKERPERKS_HOME = "https://makerperks.com";
