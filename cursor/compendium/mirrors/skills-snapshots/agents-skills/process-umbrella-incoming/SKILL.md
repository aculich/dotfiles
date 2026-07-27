---
name: process-umbrella-incoming
description: Classifies and routes unscoped drops from the repo-root incoming/ inbox across engagements/, procurement/, compliance/, and client-shared/; stages new RFP/RFO signals under incoming/opportunities/ and promotes confirmed stubs via git mv to engagements/<slug>/; appends incoming/ROUTING-LOG.md. Use when the user says process incoming, triage inbox, route this eml, new RFP or RFO in email, or when material landed at repo root without an engagement owner. Pair with meeting-sync Phase 1b after the engagement is known; pair with bootstrap-umbrella on apply passes that clear opportunities/.
disable-model-invocation: true
metadata:
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
---

# Process umbrella incoming

## Scope vs meeting-sync

| Skill | Inbox | Outcome |
|-------|-------|---------|
| **This skill** | Repo-root `incoming/` (from `conventions.md`: `incoming_dir`, `routing_log`) | Cross-engagement routing, opportunity stubs, **ROUTING-LOG** row, archive to `incoming/processed/YYYY-MM/` |
| **meeting-sync** Phase 1b | `engagements/<slug>/incoming/` | Comms markdown + engagement `STATUS.md` only |

## Workflow

1. Read `incoming/README.md`, `.context/conventions.md`, **`.context/engagements.md`**.
2. Scan `incoming/*` (skip `processed/`). Include **`opportunities/`** when the user asks to process opportunities, clear the inbox, or an **`/bootstrap-umbrella` apply** pass is promoting stubs to **`engagements/<slug>/`**.
3. Parse `.eml` (stdlib `email`): Date, From, To, Subject; PDF/DOCX: filename + optional `pdftotext` snippet.
4. **Classify:** engagement-update | procurement | compliance | client-shared | new-opportunity | ambiguous.
5. **Route** — create/update markdown under destination; never paste full secrets into git if policy forbids.
6. **Append `ROUTING-LOG.md`** (newest first table row): processed_at, source, classification, destination, engagement_slug, action, notes.
7. **Refresh root `README.md`** — update **`## Workspace activity`**: set **Umbrella incoming** row **Last activity** (latest `processed_at` from the log row you added, or **today**), recompute **Status** from **`.context/conventions.md`** thresholds, set **`Repo last update:`** to **today** if any row changed.
8. **Archive** — prefer **`incoming/opportunities/<stub>/originals/`** for tracked PDF/`.eml` next to an opportunity stub; otherwise `mv` to `incoming/processed/YYYY-MM/` (see repo `incoming/README.md` + `.gitignore`).
9. **New opportunity** — folder `incoming/opportunities/<YYYY-MM-short>/opportunity.md` with YAML (`status: triage`, `suggested_engagement_slug`). After human confirms: **`git mv`** the whole stub folder to **`engagements/<slug>/`** (preferred over copy — preserves history), add missing `README.md` / `STATUS.md` / `incoming/` / `communications/` / stub `granola/index.json` as needed, add registry row, **`decisions.md`** entry, **`ROUTING-LOG.md`** row, refresh root **`README.md`** workspace activity. **`/bootstrap-umbrella` apply** may perform this promotion together with other root hygiene moves.

## Low confidence

Write `incoming/_review/REVIEW-YYYY-MM-DD-topic.md` (one paragraph + pointer to archived original).

## Outputs checklist

- [ ] `ROUTING-LOG.md` updated for every item
- [ ] Ambiguous items in `_review/` when needed
- [ ] `next-actions.md` / `decisions.md` touched when new engagement opened
- [ ] Root **`README.md`** — **`## Workspace activity`**: **Umbrella incoming** row + **Status** + **`Repo last update`** per **`.context/conventions.md`**

## Automation (`just` + CLIs)

- End of run: suggest **`just`** at repo root (read-only) so the human sees git + `incoming/` + `ROUTING-LOG` excerpt; see repo **`docs/AUTOMATION.md`**.
- Slash **Skill** runs in **Cursor IDE** only; `just` cannot invoke it. Optional scripted read-only audit: **`cursor-agent --print --mode plan`** with this skill pasted as the prompt.
