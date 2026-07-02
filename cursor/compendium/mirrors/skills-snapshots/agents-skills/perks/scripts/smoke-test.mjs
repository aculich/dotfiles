#!/usr/bin/env node
/**
 * Smoke test for perks skill scripts (uses fixtures, no network).
 */
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const scriptsDir = path.join(__dirname, "..", "scripts");
const fixturesDir = path.join(scriptsDir, "fixtures");
const tmpDir = fs.mkdtempSync(path.join(__dirname, "..", ".test-"));

const sampleProject = path.join(tmpDir, "sample-app");
fs.mkdirSync(sampleProject, { recursive: true });
fs.copyFileSync(
  path.join(fixturesDir, "sample-package.json"),
  path.join(sampleProject, "package.json"),
);

let failed = 0;

function run(label, cmd, args, opts = {}) {
  const r = spawnSync(cmd, args, { encoding: "utf8", ...opts });
  if (r.status !== 0) {
    console.error(`FAIL ${label}`);
    console.error(r.stderr || r.stdout);
    failed++;
    return null;
  }
  console.log(`OK   ${label}`);
  return r.stdout;
}

const profileOut = path.join(tmpDir, "profile.json");
run("scan-stack", process.execPath, [
  path.join(scriptsDir, "scan-stack.mjs"),
  sampleProject,
  "--out",
  profileOut,
]);

const profile = JSON.parse(fs.readFileSync(profileOut, "utf8"));
if (!profile.packages.includes("stripe")) {
  console.error("FAIL scan-stack: expected stripe in packages");
  failed++;
} else {
  console.log("OK   scan-stack detected stripe");
}

const matchOut = run("match-perks", process.execPath, [
  path.join(scriptsDir, "match-perks.mjs"),
  "--profile",
  profileOut,
  "--personas",
  "startup",
  "--fixtures",
  path.join(fixturesDir, "mock-perks.json"),
]);

if (matchOut) {
  const match = JSON.parse(matchOut);
  const directProviders = match.tiers.direct.map((p) => p.provider);
  if (!directProviders.includes("posthog") && !directProviders.includes("stripe-atlas")) {
    console.error("FAIL match-perks: expected posthog or stripe-atlas in direct matches");
    failed++;
  } else {
    console.log("OK   match-perks direct vendor match");
  }
}

const md = run("generate-perks", process.execPath, [
  path.join(scriptsDir, "generate-perks.mjs"),
  "--project",
  sampleProject,
  "--personas",
  "startup",
  "--fixtures",
  "--dry-run",
]);

if (md && !md.includes("# Builder Perks")) {
  console.error("FAIL generate-perks: missing heading");
  failed++;
}

fs.rmSync(tmpDir, { recursive: true, force: true });

if (failed) {
  console.error(`\n${failed} test(s) failed`);
  process.exit(1);
}
console.log("\nAll perks skill smoke tests passed");
