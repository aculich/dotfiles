---
name: cidr-bootstrap-project
description: Bootstraps a new CiDR Lab / Eviction Research Network (ERN) research project in `~/projects/cidr-<county>-<topic>/` modeled on the cidr-marin-courts pattern — research repo skeleton (`01-background/`, `02-request-materials/`, `03-data-received/`, `04-analysis/`, `05-reports/`, `shared/`, `docs/`), top-level `.context/` for intent and engineering notes, `incoming/` for unprocessed `.eml` and document drops, gitignored upstream nested clones (`evictionresearch/<state>`, `evictionresearch/hprm`, `cidrlab/library`), CIDR-specific stub `AGENTS.md`/`README.md`/`ARCHITECTURE.md`/`ACTION-PLAN.md`, and a decision workflow for nested git (submodule vs subtree vs gitignored upstream/). Use when starting a new CiDR/ERN research engagement, normalizing a workspace for a new county or jurisdiction, processing an `.eml` drop into a fresh project, or restructuring a workspace that needs the cidr-marin-courts conventions. Pairs with `context-engineering` (fills `.context/`), `meeting-sync` (transcript ingest), and the cidrlab/cidr-marin-courts repo as the canonical reference.
disable-model-invocation: true
---

# Bootstrap a new CiDR / ERN research project

CIDR-specialized adaptation of the generic bootstrap-new-project pattern. Keeps the same git-topology, `.context/`, and `incoming/` discipline, but pre-bakes the **cidr-marin-courts** layout: `01-background/`, `02-request-materials/`, `03-data-received/`, `04-analysis/`, `05-reports/`, `shared/`, gitignored nested clones, `make sow-pdf` slot, and a CIDR-style `AGENTS.md`.

## When to apply

User is:

- Starting a **new CiDR / ERN engagement** (e.g. a new county, a new contract with a regional collaborative, a new jurisdiction-specific HPRM rollout).
- Has dropped an **email thread (`.eml`)** or signed contract into `~/projects/cidr-org/incoming/` and wants a dedicated repo to track that engagement end-to-end.
- Wants to mirror the **cidr-marin-courts** structure for a new project (so agents recognize the conventions and `meeting-sync` / `context-engineering` skills work without per-project rewiring).

If the project is **not** a CiDR / ERN research engagement, prefer the generic `bootstrap-new-project` flow.

## What this skill produces

A new repo at `~/projects/cidr-<county>-<topic>/` (default location; user may override) with this layout:

```
cidr-<county>-<topic>/
├── README.md                          # human-facing summary
├── AGENTS.md                          # agent memory (preferences, paths, hooks)
├── ARCHITECTURE.md                    # how the pieces fit (this repo + nested clones)
├── ACTION-PLAN.md                     # master plan: tracks, timeline, owners
├── Makefile                           # optional sow-pdf hooks (copy from cidr-marin-courts)
├── .gitignore                         # OS / Python / R / data carve-outs (see template)
├── .context/                          # intent + context + values (read context-engineering skill)
│   ├── README.md
│   ├── conventions.md
│   ├── project.md
│   ├── intent.md
│   ├── values.md
│   ├── people.md
│   ├── decisions.md
│   ├── next-actions.md
│   ├── domain-knowledge.md
│   ├── outcomes.md
│   ├── monitor.md
│   └── sensitive-topics.md
├── incoming/                          # gitignored — .eml drops, exports, screenshots
│   └── README.md                      # explains the inbox workflow
├── 01-background/                     # research, meeting notes, source materials
│   ├── transcripts/
│   └── sources/
│       ├── pdfs/
│       ├── web-snapshots/
│       └── legal-statutes/
├── 02-request-materials/              # SOW, contracts, comms log
│   ├── scope-of-work.md
│   ├── letterhead-<county>-sow.md
│   └── communications/
│       ├── README.md
│       └── STATUS.md
├── 03-data-received/                  # data deliveries (gitignored if large)
├── 04-analysis/                       # pointer; real analysis goes to evictionresearch/<state>
├── 05-reports/                        # pointer; published reports live on ERN/CiDR sites
├── shared/                            # outbound bundles + manifests/ (provenance)
│   ├── README.md
│   └── manifests/
├── docs/                              # cross-cutting docs (sow-vN-change-analysis, sharing, etc.)
├── outofscope/                        # gitignored — adjacent topics, personal calendar bits
└── (nested clones, ALL gitignored)
    ├── evictionresearch/<state>/      # e.g. evictionresearch/california/
    ├── evictionresearch/hprm/         # if HPRM project — sanmateo branch, etc.
    └── library/                       # cidrlab/library or evictionresearch/library
```

## 0. Read first

Before writing anything, read these from the canonical reference:

- `~/projects/cidr-marin-courts/README.md` — top-level human view
- `~/projects/cidr-marin-courts/AGENTS.md` — agent preferences, hooks, gotchas
- `~/projects/cidr-marin-courts/.gitignore` — full carve-outs
- `~/projects/cidr-marin-courts/.context/README.md` and `conventions.md` — file map + machine paths
- The user's email drop in `~/projects/cidr-org/incoming/<thread>.eml` — for parties, fees, and timeline

If `~/projects/cidr-marin-courts/` is missing, fall back to this skill's `scaffold/` directory and ask the user where the canonical reference lives.

## 1. Gather requirements (ask the user)

Confirm before scaffolding (prefer `AskQuestion` when available; otherwise inline):

| Question | Why |
|----------|-----|
| **Project slug** (e.g. `cidr-san-mateo-21elements`, `cidr-marin-courts`) | Repo dir name + GitHub remote |
| **County / region** (e.g. San Mateo, Marin, Alameda) | Used in `.context/project.md`, `people.md`, doc names |
| **Primary topic** (HPRM / courts / sheriff / Legal Aid / writs / consulting) | Drives folder emphasis + `domain-knowledge.md` |
| **Funder / counterparty** (e.g. CORO, 21 Elements / Planning Collaborative, county DoH) | Decides `letterhead-*-sow.md`, signature block, invoice path |
| **GitHub org and visibility** (cidrlab vs evictionresearch; private by default) | `gh repo create` later |
| **Related upstream repos** to nest as gitignored clones (e.g. `evictionresearch/california`, `evictionresearch/hprm` (sanmateo branch), `cidrlab/library`) | Sets up `.gitignore` + clone steps + `ARCHITECTURE.md` |
| **Initial `.eml` source** in `~/projects/cidr-org/incoming/` to copy into the new repo's `incoming/` | Bootstraps comms history |
| **Period of performance** + **report deadline** (best guess from email) | `intent.md`, `outcomes.md`, `next-actions.md` |

If the user has already named everything in their request, do not re-ask — proceed.

## 2. Classify git topology (CIDR defaults)

CIDR research projects almost always use the same pattern; only override on user request:

| Path | Default pattern | Why |
|------|-----------------|-----|
| **`evictionresearch/<state>/`** (e.g. `evictionresearch/california/`) | **Gitignored sibling clone** (separate `.git`) | ERN repo has its own release cycle, large data files, distinct contributor set. One source of truth for analysis stays in the ERN repo. |
| **`evictionresearch/hprm/`** | **Gitignored sibling clone**, optionally on the `<state>` or `<county>` branch (e.g. `sanmateo`) | HPRM is shared infrastructure; do not vendor. |
| **`library/`** (cidrlab/library OR evictionresearch/library) | **Gitignored sibling clone** | Org-wide grants / strategy / proposals — separate scope. |
| **`upstream/`** (other deps) | **Gitignored sibling clone** | Same reasoning; document in `ARCHITECTURE.md`. |
| **Project-owned code** | **Single `.git` at repo root**; no nested `.git` inside tracked paths. | Avoids submodule fragility for admin/research repos. |

**Rule:** at most one source-of-truth git root for any path the parent repo tracks. If a subdirectory needs independent push/pull, pick **submodule**, **subtree**, or **gitignored sibling clone** — and document the choice in `ARCHITECTURE.md` and `.context/decisions.md` so future agents know which repo "owns" PRs.

## 3. Create the directory skeleton

Working from the project root the user picked (default `~/projects/<slug>/`):

```bash
mkdir -p \
  .context \
  incoming \
  01-background/transcripts \
  01-background/sources/pdfs \
  01-background/sources/web-snapshots \
  01-background/sources/legal-statutes \
  02-request-materials/communications \
  03-data-received \
  04-analysis \
  05-reports \
  shared/manifests \
  docs \
  outofscope
```

Add `.gitkeep` to empty dirs that should ship in git (e.g. `03-data-received/.gitkeep`, `05-reports/.gitkeep`, `shared/manifests/.gitkeep`); do NOT add `.gitkeep` to `incoming/`, `outofscope/`, or `library/` (they stay gitignored).

## 4. Seed the top-level files

Create stubs in this order; each file points at where the user should expand it.

### `.gitignore`

Use the cidr-marin-courts `.gitignore` as the source of truth. Key blocks (verbatim or trimmed):

```gitignore
# --- OS ---
.DS_Store
Thumbs.db
Desktop.ini

# --- Python ---
__pycache__/
*.py[cod]
.venv/
.pytest_cache/
.mypy_cache/
.ruff_cache/

# --- R ---
.Rhistory
.RData
.Ruserdata
.Rproj.user/

# --- Office / document editors (temp / lock) ---
~$*
.~lock.*

# --- Logs & local env files ---
*.log
.env
.env.*
!.env.example

# --- Local IDE / sandboxes (not shared) ---
.vscode/
evictionresearch/
library/

# --- Shared SOW bundles: commit shared/manifests + artifacts (see shared/README.md) ---
shared/gdrive-downloads/
shared/*.eml
/incoming/

# --- Local-only meeting carve-outs (adjacent topics, personal detail); never commit ---
outofscope/

# --- SOW analysis scaffold (regenerate with `make sow-analysis`) ---
docs/_sow-change-analysis-SKELETON.md
02-request-materials/communications/_email-register-SKELETON.md
```

Add per-project lines (e.g. ignore a specific upstream clone path).

### `README.md`

Brief, human-facing. Include: one-line summary, executive summary paragraph, repo layout tree, key documents table, and a "Status" footer with an ISO date. Mirror cidr-marin-courts/README.md structure; do not invent fields.

### `AGENTS.md`

Cidr-marin-courts/AGENTS.md is the canonical template. Required sections:

- **Learned User Preferences** (at minimum: `gh` CLI for org repos; keep machine-only artifacts in `.git/info/exclude`).
- **Learned Workspace Facts** (paths to `.context/conventions.md`, meeting privacy doc, Make targets, hooks).
- Pointer to `meeting-sync` and `context-engineering` skills.

### `ARCHITECTURE.md`

Diagram (text or mermaid) showing:

- This repo (admin / SOW / comms)
- Nested gitignored clones (`evictionresearch/<state>`, `evictionresearch/hprm`, `library/`)
- Where research outputs actually live (usually the ERN state repo)
- Where the published report ends up (ERN site + CiDR site)
- How `meeting-sync` and `context-engineering` flow into `.context/`

### `ACTION-PLAN.md`

Master plan with tracks, owners, dates, and a contact list. Reverse-chronological "Status" log at the top. Pull initial entries from the seed `.eml` plus user input.

### `incoming/README.md`

Short note: this folder is gitignored, drop `.eml`/exports here, agents process them via `meeting-sync` / `context-engineering` and file structured summaries under `02-request-materials/communications/`.

### `02-request-materials/communications/README.md`

Naming scheme (`YYYY-MM-DD-NNN-short-description.md`), required frontmatter (date, comms_id, direction, parties, status), and `STATUS.md` schema. Copy from cidr-marin-courts/02-request-materials/communications/README.md if present.

### `02-request-materials/communications/STATUS.md`

Dashboard table: open threads, awaiting whom, last touch date, link to comm files.

### `shared/README.md`

What goes in `shared/`: outbound bundle copies + manifests/ provenance YAML; the SOW PDF / DOCX shared with funders; Drive download cache (gitignored). Mirror cidr-marin-courts/shared/README.md.

### `Makefile` (optional)

Only add if the project will produce SOW PDFs. Copy `make sow-pdf`, `make sow-docx`, `make share-sow`, `make sow-analysis`, `make fetch-logos` targets from cidr-marin-courts/Makefile and re-point paths to the new project's `02-request-materials/scope-of-work.md` and `letterhead-<county>-sow.md`. Document Pandoc + XeLaTeX prereqs in `README.md`.

## 5. Seed `.context/` (then hand off to context-engineering)

This skill writes **stubs** for all twelve `.context/` files (eleven from the context-engineering map + `sensitive-topics.md` from the cidr-marin-courts pattern). Use this skill's `scaffold/` directory as the source.

| File | Stub source | Required fill on first pass |
|------|-------------|------------------------------|
| `README.md` | scaffold | File map; pointers to `meeting-sync` and conventions |
| `conventions.md` | scaffold | `project_slug`, `repo_root`, `incoming_dir`, `communications_dir`, `granola.title_filters`, `zoom.host_user_id`, upstream clone paths |
| `project.md` | scaffold | One-line summary, status (date), goals, key constraints, what's next |
| `intent.md` | scaffold | Goals, success criteria, audience, tone, non-goals (TODO markers OK; user fills) |
| `values.md` | scaffold | Guardrails (MUST NOT) + guiderails (SHOULD); always include "no defendant names" if court data is in scope |
| `people.md` | scaffold | Core team + counterparties from the `.eml` thread + GitHub issues; emails; roles |
| `decisions.md` | scaffold | Initial entries: project naming, git topology, package tier (if applicable), period of performance, signatory chain |
| `next-actions.md` | scaffold | First action is usually **sign + send the contract**; second is **kickoff comms**; mirror the cidr-marin-courts table format |
| `domain-knowledge.md` | scaffold | Topic-specific facts (HPRM model, court access law for the county, Legal Aid landscape if relevant) |
| `outcomes.md` | scaffold | Desired vs expected outcomes table; tie indicators to SOW deliverables |
| `monitor.md` | scaffold | External watch table (legislation, court web, partner cadence, GitHub issues) |
| `sensitive-topics.md` | scaffold | DO NOT / CAREFUL WITH / GOOD FRAMING — copy structure from cidr-marin-courts; tailor to local political context |

After writing stubs, **hand off to the `context-engineering` skill** for substantive synthesis from the `.eml` thread and any GitHub issues you searched.

## 6. Move (don't lose) the email drops

If the user pointed at one or more `.eml` files in `~/projects/cidr-org/incoming/`:

1. **Copy** (do not move/delete the originals — see user rule about not deleting files) the relevant `.eml` files into `<new-repo>/incoming/`.
2. Note in `02-request-materials/communications/STATUS.md` that the originals still live in `cidr-org/incoming/` until the user manually retires them.
3. Do NOT process the `.eml` into structured comms in this bootstrap pass; that is `context-engineering` + `meeting-sync` work.

Example:

```bash
cp "/Users/me/projects/cidr-org/incoming/<subject>.eml" \
   "<new-repo>/incoming/"
```

## 7. Pre-fill what you can infer

Without inventing facts, fill the obvious slots:

- `.context/conventions.md` → `project_slug`, `repo_root`, `github_remote` (e.g. `cidrlab/<slug>`)
- `.context/people.md` → every party visible in the `.eml` headers + `From:` quotes (name, email, role inferred from sign-off)
- `.context/decisions.md` → "**D1**: Project bootstrapped from email thread `<subject>` on `<date>`; package tier / fee / period of performance per email"
- `.context/next-actions.md` → first row "Sign + return contract to Rachel" (or whoever the email asked) with **OWNER: Aaron**, **STATUS: ASAP**

Leave **TODO / REVIEW** markers anywhere the email is silent — do not invent.

## 8. Initialize git (do NOT push)

```bash
cd <new-repo>
git init -b main
git add .
git -c "commit.gpgsign=false" commit -m "Bootstrap <slug> from cidr-bootstrap-project skill"
```

Do **not** create the GitHub remote or push. Tell the user the suggested next step:

```bash
gh repo create cidrlab/<slug> --private --source=. --remote=origin --push
```

…and let them run it after they've reviewed `.context/` and `AGENTS.md`.

## 9. Attach Google Workspace tools

Bind the new repo to the **cidrlab** org so Cursor agents use `aaron@cidrlab.org` by default (work account). Auth and OAuth live machine-wide in the controller — this step only writes project-local binding artifacts.

**Prerequisite:** controller must be ready:

```bash
cd ~/tools/google-workspace-tools && just cidrlab
```

If that fails, stop and point the user to `~/tools/google-workspace-tools/docs/cidrlab-setup.md` — do not skip attach.

**Engagement repos** (default — work-primary binding):

```bash
cd ~/tools/google-workspace-tools
just attach-project cidrlab "<new-repo-path>" none
```

This writes `.workspace-tools.json`, `.cursor/rules/cidrlab-google-workspace.mdc`, an `AGENTS.md` workspace-tools block, and `.cursor/commands/cidrlab-status.md`.

**LLC admin repos only** (not county engagements — work + admin accounts):

```bash
just attach-project cidrlab "<new-repo-path>" none \
  --rule-template llc-admin-cidrlab-google-workspace.mdc
```

Confirm `.workspace-tools.json` exists at the repo root before handing off.

## 10. Hand off to context-engineering

Final step: invoke `context-engineering` (or tell the user to invoke it) inside the new repo, pointed at the `.eml` thread that seeded the project, so it can do substantive synthesis on top of the stubs. Confirm:

- `.context/conventions.md` paths are correct (so `meeting-sync` will work)
- `.context/values.md` has at least one project-specific guardrail beyond the defaults
- `.context/sensitive-topics.md` has been touched if the project involves court data, Legal Aid, or politically contentious counties

## 11. Execution checklist

Track progress as you go:

```
- [ ] Read cidr-marin-courts canonical files (README, AGENTS.md, .gitignore, .context/conventions.md, .context/README.md)
- [ ] Confirm slug, county, topic, funder, GitHub org, upstream clones, .eml source with user
- [ ] Resolve git topology: which upstream repos are gitignored clones vs submodules vs subtree
- [ ] mkdir directory skeleton (incl. .context/, incoming/, 01-05, shared/, docs/, outofscope/)
- [ ] Write .gitignore (use cidr-marin-courts as source of truth)
- [ ] Write README.md, AGENTS.md, ARCHITECTURE.md, ACTION-PLAN.md stubs
- [ ] Write incoming/README.md, communications/README.md, communications/STATUS.md, shared/README.md
- [ ] Optional: copy Makefile + scripts/build-sow-pdf.sh if SOW PDFs are in scope
- [ ] Write all .context/ stubs from this skill's scaffold/
- [ ] Pre-fill conventions.md, people.md, decisions.md, next-actions.md from .eml + user input
- [ ] Copy (not move) seeding .eml files into incoming/
- [ ] git init + first commit (do NOT push)
- [ ] Verify `just cidrlab` in controller; run `just attach-project cidrlab <path> none`
- [ ] Confirm `.workspace-tools.json` exists at repo root
- [ ] Hand off to context-engineering for substantive .context/ synthesis
- [ ] Tell user the gh repo create command to run when ready
```

## Anti-patterns to avoid

- **Do not** push to GitHub on first run — let the user review `.context/` first.
- **Do not** invent dates, fees, or signatures from the `.eml`; quote what is there and mark the rest **TODO**.
- **Do not** delete the original `.eml` from `cidr-org/incoming/` — copy only (per user rule).
- **Do not** vendor the ERN state repo or HPRM repo into the new project's tracked tree — keep them as gitignored sibling clones unless the user explicitly says otherwise.
- **Do not** put racial estimation, defendant names, or unredacted personal phone numbers anywhere in committed markdown — `values.md` and `sensitive-topics.md` carry this rule across all CIDR projects.
- **Do not** skip the `outofscope/` gitignored carve-out — multi-topic email threads always have content that should not ship.
- **Do not** skip Workspace tools attach (step 9) — engagement repos need `aaron@cidrlab.org` binding from day one.

## See also

- **`context-engineering`** — fills `.context/` substantively after this skill writes stubs
- **`meeting-sync`** — Granola / Zoom transcript ingest into `01-background/transcripts/`
- **`bootstrap-new-project`** — generic version of this skill (use for non-CIDR projects)
- Reference repo: `~/projects/cidr-marin-courts/` (canonical structure)
- **Workspace binding:** `~/tools/google-workspace-tools` — `just attach-project cidrlab <path> none` (see step 9)
- Reference issues: `cidrlab/projects#4`, `evictionresearch/hprm#10`, ER project board #23 (San Mateo timeline)
