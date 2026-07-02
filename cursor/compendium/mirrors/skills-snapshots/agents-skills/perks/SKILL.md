---
name: perks
description: Scans lock files and project config to detect tech stack, fetches MakerPerks builder perks from makerperks.com, and writes PERKS.md with matched free credits and startup programs. Use when auditing startup credits, finding free cloud/AI credits, scanning package-lock.json or bun.lock, or generating a perks report for a codebase.
metadata:
  author: makerperks
  version: "1.0.0"
---

# MakerPerks Perks

Match a project's tech stack to builder perks (free credits, discounts, programs) from [MakerPerks](https://makerperks.com).

## When to use

- User asks for free credits, startup perks, or cloud/AI credits for their project
- Auditing `package-lock.json`, `bun.lock`, `pnpm-lock.yaml`, or other lock files
- Generating a perks report before fundraising or infra spend
- Finding MakerPerks programs relevant to dependencies already in use

## Workflow

Copy this checklist and track progress:

```
Task Progress:
- [ ] Step 1: Scan stack
- [ ] Step 2: Present summary + ask personas
- [ ] Step 3: Match perks
- [ ] Step 4: Write PERKS.md
- [ ] Step 5: Show highlights + disclaimer
```

### Step 1: Scan stack

From the **target project root** (not necessarily makerperks):

```bash
node <skill-path>/scripts/scan-stack.mjs . --out /tmp/stack-profile.json
```

After install via `npx skills add`, the skill path is typically under `.agents/skills/perks/` or `.cursor/skills/perks/`.

Present the `summary`, `ecosystems`, `providers`, and `tags` to the user.

### Step 2: Ask personas (required)

**Always ask** which MakerPerks personas apply. Use multi-select:

| ID | Label |
|----|-------|
| `startup` | Startup |
| `student` | Student |
| `oss` | Open-source maintainer |
| `indie` | Indie developer |
| `ambassador` | Ambassador |
| `nonprofit` | Non-profit |

Never assume a persona — the user must confirm.

### Step 3: Match perks

Fetch live data from `https://makerperks.com/perks.json` (preferred) or use `--fixtures` for offline tests.

```bash
node <skill-path>/scripts/match-perks.mjs \
  --profile /tmp/stack-profile.json \
  --personas startup,oss
```

### Step 4: Write PERKS.md

Generate the report at the **target project root**:

```bash
node <skill-path>/scripts/generate-perks.mjs \
  --personas startup,oss \
  --out PERKS.md
```

If `PERKS.md` already exists, ask whether to replace or merge before overwriting.

### Step 5: Highlights + disclaimer

Show the top 5 matched programs in chat. Remind the user:

> Always confirm the current offer on each provider's official page before applying.

## Data sources

| URL | Use |
|-----|-----|
| `https://makerperks.com/perks.json` | Primary — structured matching |
| `https://makerperks.com/llms.txt` | Curated index by persona |
| `https://makerperks.com/llms-full.txt` | Full program details when needed |

## Matching tiers

1. **Direct vendor** — dependency/config maps to `provider_slug`
2. **Tag overlap** — stack tags match program `tags[]`
3. **Gateways** — aggregators (e.g. YC, Stripe Atlas) for startup persona
4. **High-value general** — top startup programs by value not already listed

## Scripts reference

| Script | Purpose |
|--------|---------|
| `scripts/scan-stack.mjs` | Detect lock files, deps, vendors, tags |
| `scripts/match-perks.mjs` | Rank programs against profile + personas |
| `scripts/generate-perks.mjs` | Full pipeline → `PERKS.md` |

See [reference/lock-files.md](reference/lock-files.md) and [reference/stack-tags.md](reference/stack-tags.md) for scan details.

## Install

```bash
npx skills add natea/makerperks@perks -g -y
```

## Dry-run (no network)

```bash
node skills/perks/scripts/generate-perks.mjs --personas startup --fixtures --dry-run
```
