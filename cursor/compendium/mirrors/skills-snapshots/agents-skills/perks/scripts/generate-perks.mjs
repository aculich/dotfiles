#!/usr/bin/env node
/**
 * Orchestrator: scan stack → match perks → write PERKS.md
 *
 * Usage:
 *   node generate-perks.mjs --personas startup --out PERKS.md
 *   node generate-perks.mjs --personas startup,oss --dry-run --fixtures
 *   node generate-perks.mjs --project /path/to/repo --personas startup
 */
import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { parseArgs, loadJson, skillRootFromImportMeta, MAKERPERKS_HOME, PERKS_JSON_URL } from "./lib.mjs";

const args = parseArgs(process.argv);
const skillRoot = skillRootFromImportMeta(import.meta.url);
const scriptsDir = path.join(skillRoot, "scripts");
const projectRoot = path.resolve(args.project || process.cwd());
const outFile = path.resolve(args.out || path.join(projectRoot, "PERKS.md"));
const dryRun = Boolean(args["dry-run"]);
const useFixtures = Boolean(args.fixtures);

if (!args.personas) {
  console.error("Usage: generate-perks.mjs --personas startup[,oss,...] [--project dir] [--out PERKS.md] [--dry-run] [--fixtures]");
  process.exit(1);
}

const profilePath = path.join(projectRoot, ".perks-stack-profile.json");
const matchPath = path.join(projectRoot, ".perks-match-result.json");
const fixturesPerks = path.join(scriptsDir, "fixtures/mock-perks.json");

const scan = spawnSync(
  process.execPath,
  [path.join(scriptsDir, "scan-stack.mjs"), projectRoot, "--out", profilePath],
  { encoding: "utf8" },
);
if (scan.status !== 0) {
  console.error(scan.stderr || scan.stdout);
  process.exit(scan.status || 1);
}

const matchArgs = [
  path.join(scriptsDir, "match-perks.mjs"),
  "--profile",
  profilePath,
  "--personas",
  args.personas,
];
if (useFixtures) matchArgs.push("--fixtures", fixturesPerks);

const match = spawnSync(process.execPath, matchArgs, { encoding: "utf8" });
if (match.status !== 0) {
  console.error(match.stderr || match.stdout);
  process.exit(match.status || 1);
}

const matchResult = JSON.parse(match.stdout);
fs.writeFileSync(matchPath, JSON.stringify(matchResult, null, 2) + "\n");

const profile = loadJson(profilePath);
const markdown = renderPerksMd(profile, matchResult);

if (dryRun) {
  console.log(markdown);
} else {
  fs.writeFileSync(outFile, markdown);
  console.error(`Wrote ${outFile}`);
}

if (!args["keep-temp"]) {
  for (const f of [profilePath, matchPath]) {
    try {
      fs.unlinkSync(f);
    } catch {
      /* ignore */
    }
  }
}

function renderPerksMd(profile, match) {
  const date = new Date().toISOString().slice(0, 10);
  const personaLabels = match.personas.join(", ");
  const lines = [
    "# Builder Perks",
    "",
    `> Generated ${date} by the [MakerPerks perks skill](https://github.com/natea/makerperks/tree/main/skills/perks).`,
    `> Source: [makerperks.com/perks.json](${PERKS_JSON_URL}). Verify eligibility on each provider's site before applying.`,
    "",
    "## Profile",
    "",
    `- **Personas:** ${personaLabels}`,
    `- **Detected stack:** ${profile.summary}`,
    "",
  ];

  if (profile.lock_files.length) {
    lines.push(`- **Lock files:** ${profile.lock_files.slice(0, 5).join(", ")}${profile.lock_files.length > 5 ? "…" : ""}`);
  }
  if (profile.providers.length) {
    lines.push(`- **Vendors detected:** ${profile.providers.join(", ")}`);
  }
  lines.push("");

  lines.push("## Matches for your stack", "");

  lines.push("### Direct vendor matches", "");
  if (match.tiers.direct.length) {
    lines.push(...tableSection(match.tiers.direct));
  } else {
    lines.push("_No direct vendor matches from your dependencies._", "");
  }

  lines.push("### Stack-adjacent programs", "");
  if (match.tiers.tags.length) {
    lines.push(...tableSection(match.tiers.tags));
  } else {
    lines.push("_No tag-based matches._", "");
  }

  lines.push("### Startup gateways & bundles", "");
  if (match.tiers.gateways.length) {
    lines.push(...tableSection(match.tiers.gateways));
  } else {
    lines.push("_No gateway programs matched._", "");
  }

  lines.push("## Also worth exploring", "");
  if (match.tiers.general.length) {
    lines.push(...tableSection(match.tiers.general));
  } else {
    lines.push("_No additional high-value programs._", "");
  }

  lines.push(
    "---",
    "",
    `Data: [llms.txt](${MAKERPERKS_HOME}/llms.txt) · [perks.json](${PERKS_JSON_URL}) · [MakerPerks](${MAKERPERKS_HOME})`,
    "",
  );

  return lines.join("\n");
}

function tableSection(items) {
  const rows = [
    "| Program | Value | Why | Apply |",
    "| --- | --- | --- | --- |",
  ];
  for (const item of items) {
    const title = `[${escapeCell(item.title)}](${item.detail_url})`;
    const value = escapeCell(item.value_display);
    const why = escapeCell(item.why);
    const apply = `[Apply](${item.url})`;
    rows.push(`| ${title} | ${value} | ${why} | ${apply} |`);
  }
  rows.push("");
  return rows;
}

function escapeCell(s) {
  return String(s).replace(/\|/g, "\\|").replace(/\n/g, " ");
}
