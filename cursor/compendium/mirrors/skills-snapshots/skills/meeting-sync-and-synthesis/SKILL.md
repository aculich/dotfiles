---
name: meeting-sync-and-synthesis
description: Ingests meeting transcripts from Granola and Zoom MCPs, pulls upstream git (including LFS-safe pulls), indexes artifacts into repo conventions, and synthesizes multi-layer project updates (capstone status, stakeholder context, vision). Use when the user asks to sync meetings, pull latest transcripts, update progress docs after a meeting, routinize Granola/Zoom/git ingest, or capture "where we are" plus big-picture narrative for a capstone or partner project.
metadata:
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
---

> **DEPRECATED** — Superseded by two generic skills (do not delete this folder per project policy):
> - **`meeting-sync`** (`~/.cursor/skills/meeting-sync/SKILL.md`) — Phases 1–2 ingest + index; reads **`.context/conventions.md`**.
> - **`context-engineering`** (`~/.cursor/skills/context-engineering/SKILL.md`) — three-pillar `.context/` lifecycle + Phases 3–4 synthesis + grounding.
>
> Prefer bootstrapping **`.context/`** and project **`conventions.md`** instead of embedding project paths only in this skill’s `project-conventions.md`.

# Meeting sync and synthesis

Run this workflow when refreshing project state after meetings. Adapt paths and names to the repo; see [project-conventions.md](project-conventions.md) for the **crb-macss-fiscal** MaCSS example.

## Preconditions

- Granola and Zoom MCPs configured (see project `.cursor/mcp.json`). In Cursor, the Granola server identifier is often `user-granola` (not `granola`) — use the MCP tool picker or project `mcps/` descriptors to confirm.
- If Zoom cloud recordings are under a specific host account, use that `user_id` (email or Zoom user id).
- On auth errors: stop and ask the user (see project `AGENTS.md` if present).

## Phase 1 — Ingest

### Granola

1. `list_meetings` with `time_range: custom` and `custom_start` / `custom_end` bracketing the target day(s).
2. Identify the meeting row (title, id). Prefer **MaCSS** / **MaCSS-CRB** titles when multiple exist.
3. `get_meeting_transcript` with `meeting_id` for verbatim text (quotes, attribution).
4. `get_meetings` with `meeting_ids` for summary, attendees, private notes (max 10 ids per call).
5. For thematic questions across notes: `query_granola_meetings` with a precise query. **Preserve citation links** from the response when passing them to the user.

### Zoom

1. `list_recordings` with `user_id`, optional `from` / `to` (`yyyy-MM-dd`), paginate with `next_page_token` if needed.
2. For each relevant recording: `get_meeting_recordings` with `meeting_id` to discover transcript / VTT download URLs or file metadata.
3. If meeting may still be live: `list_live_meetings` then `get_live_meeting_participants` only when needed (no transcript until ended).

### Git (each upstream clone)

1. Prefer work on a local branch; keep tracking branch current per project `AGENTS.md`.
2. If `git pull` fails on **Git LFS smudge** (404): `GIT_LFS_SKIP_SMUDGE=1 git pull` and **record** which paths remain pointer-only.
3. If dirty tree blocks pull: `git stash` → pull → `git stash pop` (user permission for destructive ops per project rules).

### Optional documents

- If a **.docx** report has figures: `unzip -j -o "file.docx" "word/media/*" -d docs/.../assets/` (or project-standard assets path).

## Phase 2 — Index and store

1. **Granola mirror:** `granola/<namespace>/<uuid-prefix>_<SanitizedTitle>_<MonDDYYYY>/` with `transcript.txt`, `metadata.json` (id, title, date, participants, provenance), optional `notes_info.md` (Granola web URL, MCP provenance).
2. **Zoom cloud mirror:** `<transcripts_root>/<YYYY-MM-DD>_<Title>/` with `transcript.VTT`, `closed_caption.VTT`, `chat.TXT` as returned by fetch scripts or MCP.
3. Update **`index.json`** in both trees (append meeting object; bump `last_curated_at` / `curated_at`).
4. **`notes/<YYYY-MM-DD>-<project>-transcript.md`:** stub only — list canonical paths + Granola URL; do not duplicate full transcript.
5. **`notes/<YYYY-MM-DD>-<project>-notes.md`:** structured notes: Context, Key points (bullets), Action items (owner + due if known), Links to indices.

## Phase 3 — Synthesize (three layers)

### Layer 1 — Capstone / operational (edit canonical docs)

- Read new notes + transcript pointers + existing **PROGRESS** and **CAPSTONE** docs.
- Update PROGRESS: "As of" date, Section 2 (current status), sources line, bullets for parsing / crosswalk / data / cadence / milestones.
- Update CAPSTONE only if student scope or deliverables changed.
- Explicitly answer in prose or bullets:
  - **What story can we tell with the data we can access?**
  - **What is missing from the data** that blocks or weakens that story?

### Layer 2 — Stakeholder / institutional (draft first)

- Add or extend **`notes/<YYYY-MM-DD>-synthesis-draft.md`** (do not merge huge narrative into EXECSUMMARY until reviewed unless user asks).
- Cover: legislative / agency feedback, process knowledge not in databases, "expertise in heads" and org-specific systems.

### Layer 3 — Vision / future

- Same draft file: forward-looking framing (e.g. tooling at scale, listening / sensemaking metaphors, handoff, CRB long arc). Tie to existing **EXECSUMMARY** / **GROUNDING** only with clear attribution ("discussed on DATE").

## Phase 4 — Analyze (data grounding)

1. List new/changed files in upstream repos since last known commit (short `git log -1 --oneline`, `git diff --stat` optional).
2. Map spoken or written claims to **code paths** (e.g. integration notebook, design doc) and **data artifacts** (CSVs referenced in docs).
3. Produce a short **grounding table**: claim | evidence in repo | status (verified / pointer-only LFS / missing / not in repo).

## Outputs checklist

- [ ] Granola folder + `transcript.txt` + `metadata.json` (+ optional `notes_info.md`)
- [ ] Zoom folder + VTT/chat if obtained
- [ ] Both `index.json` files updated
- [ ] `notes/*-transcript.md` stub + `notes/*-notes.md`
- [ ] PROGRESS (and CAPSTONE if needed) updated
- [ ] `notes/*-synthesis-draft.md` with layers 2–3 + data gaps
- [ ] Grounding paragraph or table in synthesis-draft or notes

## Re-run cadence

Weekly after recurring sync meetings, or on demand after stakeholder calls.
