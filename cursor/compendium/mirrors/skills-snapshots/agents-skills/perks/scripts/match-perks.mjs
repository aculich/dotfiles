#!/usr/bin/env node
/**
 * Match MakerPerks programs to a stack profile and personas.
 *
 * Usage:
 *   node match-perks.mjs --profile stack.json --personas startup,oss
 *   node match-perks.mjs --profile stack.json --personas startup --fixtures perks.json
 */
import fs from "node:fs";
import {
  parseArgs,
  loadJson,
  PERSONAS,
  PERKS_JSON_URL,
  MAKERPERKS_HOME,
} from "./lib.mjs";

const args = parseArgs(process.argv);

if (!args.profile) {
  console.error("Usage: match-perks.mjs --profile stack.json --personas startup[,oss,...] [--fixtures perks.json]");
  process.exit(1);
}

const profile = loadJson(args.profile);
const personas = (args.personas || "startup")
  .split(",")
  .map((p) => p.trim())
  .filter((p) => PERSONAS.includes(p));

if (!personas.length) {
  console.error(`Invalid personas. Choose from: ${PERSONAS.join(", ")}`);
  process.exit(1);
}

const perksData = args.fixtures
  ? loadJson(args.fixtures)
  : await fetchJson(PERKS_JSON_URL);

const programs = perksData.programs.filter((p) =>
  p.audience.some((a) => personas.includes(a)),
);

const matchedSlugs = new Set();
const tagCandidates = [];
const tiers = {
  direct: [],
  tags: [],
  gateways: [],
  general: [],
};

for (const program of programs) {
  if (profile.providers.includes(program.provider)) {
    tiers.direct.push(withMatch(program, `Uses ${program.provider} in your stack`));
    matchedSlugs.add(program.slug);
  }
}

for (const program of programs) {
  if (matchedSlugs.has(program.slug)) continue;
  const overlap = (program.tags || []).filter((t) => profile.tags.includes(t));
  if (overlap.length) {
    tagCandidates.push({ program, overlap });
  }
}

for (const { program, overlap } of tagCandidates
  .sort((a, b) => (b.program.max_value || 0) - (a.program.max_value || 0))
  .slice(0, 15)) {
  tiers.tags.push(withMatch(program, `Stack tags: ${overlap.join(", ")}`));
  matchedSlugs.add(program.slug);
}

if (personas.includes("startup")) {
  for (const program of programs) {
    if (matchedSlugs.has(program.slug)) continue;
    if (program.aggregator) {
      tiers.gateways.push(
        withMatch(program, "Startup gateway — unlocks multiple partner deals"),
      );
      matchedSlugs.add(program.slug);
    }
  }
}

const generalCandidates = programs
  .filter((p) => !matchedSlugs.has(p.slug) && p.audience.includes("startup"))
  .sort((a, b) => (b.max_value || 0) - (a.max_value || 0))
  .slice(0, 10);

for (const program of generalCandidates) {
  tiers.general.push(
    withMatch(program, "High-value startup program"),
  );
}

const result = {
  matched_at: new Date().toISOString(),
  personas,
  profile_summary: profile.summary,
  perks_source: args.fixtures || PERKS_JSON_URL,
  perks_count: programs.length,
  tiers,
  highlights: [
    ...tiers.direct,
    ...tiers.tags,
    ...tiers.gateways,
  ]
    .sort((a, b) => (b.max_value || 0) - (a.max_value || 0))
    .slice(0, 5),
};

console.log(JSON.stringify(result, null, 2));

function withMatch(program, why) {
  return {
    slug: program.slug,
    title: program.title,
    provider: program.provider,
    value_display: program.value_display,
    url: program.url,
    detail_url: `${MAKERPERKS_HOME}/programs/${program.slug}`,
    audience: program.audience,
    tags: program.tags || [],
    aggregator: program.aggregator || false,
    max_value: program.max_value || 0,
    why,
  };
}

async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Failed to fetch ${url}: ${res.status}`);
  return res.json();
}
