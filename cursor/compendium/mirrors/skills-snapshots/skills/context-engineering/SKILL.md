---
name: context-engineering
description: Three-pillar (Intent / Context / Values) lifecycle for .context/ markdown — plus optional outcomes.md and monitor.md for deliverable indicators and external cadence. Supports umbrella client repos: engagements.md registry, relationship-timeline, backfill-status, promotion rules (engagement-first vs client-wide), and scaffold copies for incoming/ROUTING-LOG. Bootstrap from templates, read-before-work, update-after-work, synthesis with grounding tables, feed-forward loops. Reads .context/conventions.md for machine paths. Use when scaffolding agent context, normalizing multi-engagement clients, updating decisions/people/domain after meetings, or running Phase 3–4 synthesis after meeting-sync ingest.
---

# Context engineering (Intent · Context · Values)

Maintain a project’s **`.context/`** directory as the **technical substrate** for aligned agent behavior. Pair with **`meeting-sync`** for transcript ingest and indexing.

## The three pillars (+ optional measurement layer)

From intent/context engineering practice (see **PROVENANCE.md**):

> **Intent tells context what to want; context tells intent what to mean.**  
> **Wanting without meaning is bare appetite; meaning without wanting is inert potential.**

Add **Values** as the constraint on the loop:

- **Intent** — direction: goals, success criteria, audience, tone, what “good” looks like (**`intent.md`**).
- **Context** — interpretation: facts, people, decisions, domain mechanisms (**`project.md`**, **`people.md`**, **`decisions.md`**, **`domain-knowledge.md`**, plus machine **`conventions.md`**).
- **Values** — protection: **Guardrails** (hard limits — MUST NOT; human review; accuracy thresholds) and **Guiderails** (preferences — SHOULD: plain language, cite sources, flag uncertainty, preserve judgment) (**`values.md`**).

**Optional (recommended for delivery projects):**

- **`outcomes.md`** — bridges intent to evidence: **desired vs expected** outcomes, **indicators**, links to canonical docs (e.g. SOW), review cadence, who speaks to impact.
- **`monitor.md`** — routinized **external watch** (legislation, court websites, partner comms hygiene, ingest cadence) with escalation rules into `intent` / `outcomes` / `next-actions`.

## Where this fits (five-layer map)

Conceptually (see local **METHODS-MAP** in PROVENANCE):

1. Emotional intelligence (human substrate)  
2. Institutional ethnography (standpoint, ruling relations, texts)  
3. Deep listening (practice — PALEO, ambient capture)  
4. Tacit knowledge capture (conversation → transcript → artifacts → `.context/`)  
5. **Intent / Context / Values engineering** ← **this skill**

Layers 3–4 feed **facts** into `.context/`; this skill runs layer 5 and encodes **norms** so agents don’t lose standpoint or safety.

## The eleven-file map (nine core + two optional)

| File | Pillar | When to read |
|------|--------|----------------|
| `README.md` | meta | Onboarding agents to the convention |
| `conventions.md` | Context (machine) | **First** for automated skills — paths, MCP hints, cadence |
| `engagements.md` | Context (umbrella) | **When present** — engagement slug registry and per-stream paths |
| `project.md` | Context | Summary, status, pointers to canonical docs |
| `intent.md` | Intent | What success means this month |
| `outcomes.md` | Intent / measurement (optional) | Deliverable indicators, desired vs expected, impact narrative |
| `values.md` | Values | Guardrails + guiderails |
| `people.md` | Context | Roles, relationships |
| `decisions.md` | Context | Decision log (newest first) |
| `next-actions.md` | Intent / execution | GTD-style actions |
| `domain-knowledge.md` | Context | Facts an LLM wouldn’t infer |
| `monitor.md` | Context / cadence (optional) | Recurring external watch — bills, sites, ingest |

Projects that omit the optional pair keep the **nine-file** core (`README`, `conventions`, `project`, `intent`, `values`, `people`, `decisions`, `next-actions`, `domain-knowledge`).

## Lifecycle

### Read before work

1. `.context/conventions.md`  
2. **`.context/engagements.md`** when the repo is an **umbrella** (multi-engagement client)  
3. `.context/intent.md` + `.context/values.md` + `.context/project.md`  
4. If the project uses them: **`.context/outcomes.md`**, **`.context/monitor.md`**, **`.context/backfill-status.md`**, **`relationship-timeline.md`**.  
5. Touch **`people.md`** / **`decisions.md`** / **`domain-knowledge.md`** as needed for the task.

### Update after work

- New **decisions** → `decisions.md`  
- New **owners/dates** → `next-actions.md`  
- New **stable facts** → `domain-knowledge.md`  
- Shift in goals or norms → `intent.md` / `values.md`  
- Deliverable **indicators** or expected vs actual → **`outcomes.md`** (if present)  
- External source **cadence** or watch list changes → **`monitor.md`** (if present)  
- New **engagement** opened or renamed → **`.context/engagements.md`** + engagement `README.md` + optional engagement `.context/`
- If **paths or tools** changed → `conventions.md`
- **Umbrella repos:** after any `.context/` pillar edit that reflects new facts or owners → root **`README.md`** **`## Workspace activity`** (`.context/` row + **`Repo last update`**) per **`conventions.md`** *Workspace activity*

### Feed-forward loop

Each session’s artifacts (notes, synthesis drafts, grounding tables) become the **next** session’s context — update `.context/` rather than relying on chat memory alone.

---

## Bootstrap phase

If **`.context/` is missing** or empty:

1. Read `AGENTS.md`, `README.md`, and top-level `docs/` if present; note `git remote` and project name. Inspect for **`engagements/`** or multi-client patterns.  
2. Ask the user: **Scaffold `.context/` from templates (9 core files + optional `outcomes.md` + `monitor.md` = 11)?** For umbrella clients, also ask to add **`engagements.md`**, **`backfill-status.md`**, **`relationship-timeline.md`**, and repo-root **`incoming/`** workflow files (copy from `scaffold/incoming-README-umbrella.md` and `scaffold/ROUTING-LOG.template.md`).  
3. On yes: copy from this skill’s **`scaffold/`** into `.context/` (rename **`context-README.template.md`** → **`README.md`**; copy the other templates as-is). For delivery, contract, or policy-heavy projects, include **`outcomes.md`** and **`monitor.md`**.  
4. Pre-fill **`project.md`** and **`conventions.md`** with anything inferrable (repo name, doc paths, transcript roots if obvious). For umbrellas, set **`engagements_registry`** and per-slug rows in **`engagements.md`**.  
5. Leave **`intent.md`** and **`values.md`** with **TODO** markers for the user’s explicit priorities and guardrails.  
6. Point the user to **`README.md`** for the file map.

**Umbrella detection:** If `engagements/` exists on disk or the user describes multiple RFPs under one client, treat as umbrella — prefer **`bootstrap-umbrella-client-project`** for directory moves and git fold, then return here for `.context/` pillar files.

If **only `conventions.md` is missing** but other files exist, add **`conventions.md`** from template and merge known paths.

---

## Synthesis phase (after meeting-sync)

Use when integrating new meetings into project memory:

1. Read the meeting mirror **`sync_manifest.json`** and inspect **`raw/`** (local Zoom, cloud, Granola, Tana) — know what landed before interpreting.
2. Read new **`notes/*-notes.md`** / **`meeting-notes-*.md`** digests and transcript stubs (not necessarily full VTT).
3. Update **`decisions.md`**, **`next-actions.md`**, **`people.md`** if roles/contacts changed.  
4. **Promotion (umbrella):** write solicitation-specific facts to **`engagements/<slug>/.context/`** or engagement notes first; promote to **client** `.context/domain-knowledge.md` / `.context/decisions.md` only when the fact applies across engagements or defines the client relationship.  
5. **Layered narrative** (adapt to project): operational status → stakeholder / institutional insight → forward vision. Prefer updating a **draft** under `notes/` before promoting to canonical docs.  
6. **Grounding table:** claim | evidence path in repo (`raw/…` preferred) | status (verified / LFS pointer / missing).  
7. **Feed back into pillars:**  
   - New goals or deadlines → **`intent.md`**  
   - New non-negotiables or preferences → **`values.md`**  
   - Stable domain facts → **`domain-knowledge.md`** (or engagement `.context/` when scoped)  
   - Indicator / impact narrative shifts → **`outcomes.md`** (if present)  
   - New recurring watch or source → **`monitor.md`** (if present)  
   - After **`process-umbrella-incoming`** or new engagement → **`engagements.md`**, **`relationship-timeline.md`**, **`backfill-status.md`** as appropriate  
7. **Umbrella `README.md`:** refresh **`## Workspace activity`** per the section *Root README.md — `## Workspace activity`* below (same pass — do not leave stale **Last activity** / **Status** after synthesis).

Do **not** replace long-form canonical docs if the project already has them — **summarize and link** from `.context/`.

---

## Root README.md — `## Workspace activity` (umbrella)

When **`.context/engagements.md`** exists **and** the repo-root **`README.md`** contains a **`## Workspace activity`** section (bootstrap / human added):

1. Read **`workspace_activity_*_days`** and **`last_activity`** sourcing rules from **`.context/conventions.md`** (*Workspace activity* subsection).
2. After this skill changes any matching **track** (`.context/`, `incoming/`, `engagements/<slug>/`, `programs/`, `procurement/`, `client-shared/`, `compliance/`, `partners/`, `tools/`, …), recompute **Last activity** for **that** row using the `git log -1 --format=%cs -- <path>` rules in conventions (max across listed files for multi-file tracks).
3. Recompute **Status** from **Last activity** using **calendar days** to **today** (authoritative “today” = the user/session clock or CI date): **Active** if `≤ workspace_activity_active_days`; else **Recent** if `≤ workspace_activity_recent_days`; else **Quiet**.
4. Set **`Repo last update:`** to **today** (`YYYY-MM-DD`) whenever any row in the table changes, or when this synthesis materially updated umbrella memory even if every `last_activity` stayed the same ISO day.
5. If the section is missing but the repo is umbrella-style, merge in **`scaffold/root-readme-workspace-activity.fragment.md`** and fill rows from **`engagements.md`** plus fixed rows (incoming, `.context/`, major dirs).

Engagement **Track** column: use each registry row’s **`label`** (fallback: slug).

---

## Outputs checklist (synthesis path)

- [ ] `decisions.md` / `next-actions.md` updated if decisions or owners changed  
- [ ] Draft or canonical narrative + **grounding table**  
- [ ] `intent.md` / `values.md` touched if goals or guardrails shifted  
- [ ] `outcomes.md` / `monitor.md` touched if indicators or watch list shifted (when those files exist)  
- [ ] `conventions.md` updated if ingest paths or MCP ids changed  
- [ ] **`engagements.md`** / **`backfill-status.md`** / **`relationship-timeline.md`** touched when umbrella routing or engagement lifecycle changed  
- [ ] Root **`README.md`** — **`## Workspace activity`** table: refresh **Last activity** + **Status** for every track this session touched; bump **`Repo last update`** when any row or umbrella narrative changed

## Automation (`just` + CLIs)

- After material `.context/` or umbrella path edits, suggest the human run **`just`** at repo root (read-only default) — see repo **`docs/AUTOMATION.md`** and **`.context/conventions.md`** (`task_runner`).
- **Cursor Skills** (slash-invoked) are **not** callable from `just`; use **`cursor-agent`** / **`claude -p`** only when you want a **scripted** LLM pass (prefer **`--mode plan`** / **`--plan`** for read-only).

## See also

- **`meeting-sync`** — Tana + Granola + Zoom + **local Zoom** ingest, unified `raw/` mirrors, index, note stubs
- Skill **`PROVENANCE.md`** — citations for pillars, Wheeler wording, and upstream clones  
