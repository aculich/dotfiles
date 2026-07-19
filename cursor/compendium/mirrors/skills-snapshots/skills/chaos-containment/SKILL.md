---
name: chaos-containment
description: >-
  Inventories messy umbrella directories, classifies code vs data vs vendor
  upstreams, and proposes containment (extract repos, offload research dumps,
  quick-stash PII). Default is dry-run; help explains args. Use when the user
  says chaos-containment, clean up this umbrella, contain the mess, offload
  research data, or vacuum/vaccuum clutter with multi-destination routing.
disable-model-invocation: true
---

# Chaos-containment

Make sense of and clean up a messy umbrella directory: what is a self-contained repo, what is data vs code, what is vendor/upstream, and where heavy research dumps should live.

> Never drop data without its context and intent — leave a capsule, not a dig site.

Ethos: [`~/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md`](file:///Users/me/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md). Briefing template: [agent-briefing.md](agent-briefing.md).

## Invocation

```text
/chaos-containment              # default: inventory + classify + propose (read-only)
/chaos-containment help         # commands, taxonomy, destinations, steward principle
/chaos-containment offload …    # multi-destination relocate (aliases: vacuum, vaccuum)
/chaos-containment quick-stash …# hand off to quick-stash + AGENT-BRIEFING.md
/chaos-containment extract …    # propose promoting a nested tree to its own repo
/chaos-containment vendor-map … # document how upstreams are used
/chaos-containment apply        # execute last proposed plan after confirmation
```

Optional flags: `--root <path>`, `--depth N`, `--dry-run` (default), `--apply` (only with prior/explicit confirm).

Companion slash command: `~/.cursor/commands/chaos-containment.md`.

---

## help

When the user passes `help`, print a short reference covering:

1. **Commands** above
2. **Steward principle** (one-liner + link to `~/pdv/meta/`)
3. **Taxonomy** (classes table below)
4. **Destinations** — see [destinations.md](destinations.md)
5. **Patterns** — see [patterns.md](patterns.md); new patterns may be defined mid-run
6. **Safety** — confirm before moves; incomplete briefing = incomplete move

Do not run inventory unless they also ask for a scan.

---

## Default (no args) — do the right thing

**Right thing = inventory + classify + propose. No moves until confirmation.**

Copy this checklist:

```text
Chaos-containment:
- [ ] Resolve root (cwd or --root)
- [ ] Step 0: hot-livewires-preflight (creds/PII) — halt if verified-live until triaged
- [ ] Scan topology (depth-limited)
- [ ] Classify notable paths
- [ ] Emit containment report (mark briefing-required rows)
- [ ] Stop and wait — unless user already named paths + a verb
```

### 0. Hot livewires (mandatory before classify)

Invoke [`hot-livewires-preflight`](file:///Users/me/.cursor/skills/hot-livewires-preflight/SKILL.md):

- Scan for credentials/keys/PII with gitleaks + trufflehog (not custom regex)
- **Creds/keys** → `op://chaos` after `develop` provenance check + `ROTATION-PLAN.md` (not ordinary PII). ACTIVE trial clients also live in `chaos` until graduation. Shared LEGACY: do not provider-revoke when only one tool rotates — [`deaccession-guides-and-guards`](file:///Users/me/.cursor/skills/deaccession-guides-and-guards/SKILL.md) + [`DEACCESSIONING-GUIDE`](file:///Users/me/pdv/meta/DEACCESSIONING-GUIDE.md).
- **PII** → `quick-stash` → `~/pdv` + `AGENT-BRIEFING.md`
- Write `LIVEWIRES-BRIEFING.md`; do not continue deaccession until verified-live is triaged

If the tree looks like a **stale tooling trial** (nested third-party `.git`, personal wrapper, multi-GB `target`/`.devbox`, `.specstory`), also invoke [`stale-tooling-trial`](file:///Users/me/.cursor/skills/stale-tooling-trial/SKILL.md).

### 1. Scan

From root:

- Nested `.git` directories (depth ≤ `--depth`, default 3)
- Naming signals: `vendors/`, `upstream/`, `owner__repo`, `labs/`, `research-clones/`, `incoming/`, `apps/`
- Root loose files (especially large JSON/PDF dumps)
- Large trees: `du -sh */` (sample; do not recurse forever)
- Build artifacts: `node_modules`, `.next`, `dist` (propose ignore/delete — never vault)

### 2. Classify

| Class | Signal | Typical fate |
|-------|--------|--------------|
| `product-repo` | Own `.git`, your code | Keep / promote to `apps/` or extract as sibling |
| `vendor-upstream` | `owner__repo`, `vendors/`, `upstream/` | Keep gitignored or pin; never treat as product |
| `research-lab` | `labs/`, `research-clones/`, matrices/PRDs | Keep structure; offload heavy downloads |
| `research-data` | PDFs, paper dumps, pricing JSON, extraction results | `/offload` → Drive (or LFS/DVC if tightly coupled) |
| `pii-personal` | Mail, personal notes, non-OSS PII (not live API keys) | `quick-stash` → `~/pdv` + **AGENT-BRIEFING.md** |
| `live-credential` | API keys, OAuth secrets, tokens (from livewires) | `op://chaos` legacy item + rotation plan; check `develop` first |
| `stale-tool-trial` | Nested upstream clone + wrapper + build bloat + SpecStory | `stale-tooling-trial` → mark-and-sweep + `~/tools/*-quickstart` |
| `inbox-drop` | Root `incoming/` | Route or offload |
| `orphan-clutter` | Empty dirs, stale experiments | Propose archive/delete only after confirm |

If the tree looks like a **client engagement umbrella** (`engagements/`, `.context/engagements.md`), say so and point to `process-umbrella-incoming` / `bootstrap-umbrella-client-project` instead of forcing this taxonomy.

### 3. Containment report

Emit a markdown table:

| Path | Class | Size | Git state | Proposed action | Destination | Briefing? |
|------|-------|------|-----------|-----------------|-------------|-----------|

End with: wait for confirmation (or `/chaos-containment apply` after they approve).

---

## offload (aliases: vacuum, vaccuum)

Multi-destination relocate. Prefer the name **offload** in prose.

1. Classify sensitivity + coupling — see [destinations.md](destinations.md)
2. Route:
   - **Live credentials / API keys** → `hot-livewires-preflight` → `op://chaos` (not PDV as primary home)
   - **PII / personal** → follow **quick-stash** skill (PDV + `AGENT-BRIEFING.md`)
   - **Loose public research** → Google Drive via `gog-as` + local `OFFLOAD.md` (one-liner required)
   - **Build-coupled** → propose git-lfs or DVC; ask before introducing either; pointer README with one-liner
3. Confirm targets before transport
4. Never `rm` without explicit consent; prefer upload/move then remove
5. If a new destination pattern appears, **append** it to [patterns.md](patterns.md)

### Google Drive checklist

1. Read `.workspace-tools.json` for `gog_alias` / org
2. If missing: tell user to `attach-workspace <org>` — do not guess foreign orgs
3. Respect org isolation (bound org only unless explicit cross-org override)
4. Upload with `gog-as <alias> drive …` under something like `Chaos-Containment/<repo>/<YYYY-MM>/`
5. Write local `OFFLOAD.md` (steward one-liner + whence/purpose/Drive path)
6. Remove or gitignore local copy **only after confirm**

---

## quick-stash

Hand off to [`quick-stash`](file:///Users/me/.cursor/skills/quick-stash/SKILL.md).

**Required:** `AGENT-BRIEFING.md` per [agent-briefing.md](agent-briefing.md). Incomplete briefing = incomplete stash.

Use for PII / personal / secrets that must not stay in an OSS or project tree. Not for vacuuming already-committed history — that is `tidy-stash`.

---

## extract

Propose promoting a nested tree to its own git repo (or moving an accidental nested `.git` to a sibling path under `~/tools/` / `apps/`).

- Dry-run first: new path, remotes, what stays as vendor vs product
- Apply only after confirm
- Leave a short README at the old path (or pointer) with the steward one-liner if anything remains

---

## vendor-map

Document how upstreams are used:

| Path | Kind | How used | Tracked? |
|------|------|----------|----------|
| `vendors/foo` | pin / study clone | … | yes/no |

Do not treat vendor trees as product. Cross-link `research-clone-bootstrap` labs (`peers/clones`) when present.

---

## apply

Execute the **last proposed plan** from this conversation only after the user confirms (or the same message includes clear apply language).

For every moved batch:

- [ ] Bytes at destination
- [ ] Briefing / OFFLOAD / pointer README with one-liner
- [ ] Provenance where applicable
- [ ] Source hygiene (gitignore) if needed
- [ ] Pattern registry update if novel

---

## Safety

- Never delete without explicit consent; prefer `mv` / upload-then-remove
- Never rewrite git history unless asked → `tidy-stash`
- Never cross-org Drive without workspace binding + isolation rules
- Confirm targets before offload/stash
- **Incomplete agent briefing = incomplete move**
- Follow `accidental-data-loss-prevention` for irreversible ops

## See also

- [destinations.md](destinations.md) — PDV / Drive / LFS / DVC / chaos vault
- [patterns.md](patterns.md) — living pattern registry
- [agent-briefing.md](agent-briefing.md) — briefing template
- `hot-livewires-preflight`, `stale-tooling-trial`, `deaccession-guides-and-guards`, `quick-stash`, `tidy-stash`, `research-clone-bootstrap`
- Ethos: `~/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md`, `~/pdv/meta/DEACCESSIONING-GUIDE.md`
- `~/pdv/meta/` — Manifesto + Guide
