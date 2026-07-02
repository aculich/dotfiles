---
name: meeting-sync
description: Generic Phase 0–2 workflow — resolve engagement paths from .context/engagements.md when present; optional Phase 1a delegates repo-root incoming triage to process-umbrella-incoming; ingest meeting transcripts (Tana MCP, Granola MCP full payload, Zoom MCP/cloud); Phase Backfill upgrades light mirrors and updates backfill-status; Phase 1b processes engagement incoming .eml; git-pull upstream with LFS-safe patterns; mirror artifacts per .context/conventions.md; update indices and note stubs. Use when syncing meetings, triaging umbrella incoming, ingesting transcripts, or indexing before synthesis. Pair with context-engineering.
---

# Meeting sync (ingest + index)

Run **Phase 0 — Resolve engagement**, then **Phase 1 — Ingest** and **Phase 2 — Index** after meetings or when refreshing mirrors. **Paths** come from **`.context/conventions.md`** and, when present, **`.context/engagements.md`** (per-engagement mirror roots, inboxes, and status files). If `conventions.md` is missing, run **`context-engineering`** bootstrap first.

## Phase 0 — Resolve engagement (umbrella / multi-workstream)

When **`.context/engagements.md`** exists:

1. Read **`default_engagement_slug`** (or equivalent) from `conventions.md`, or use the slug the user explicitly named.
2. Load that row for **`granola_mirror`**, **`zoom_root`**, **`tana_mirror`** (optional), **`engagement_incoming_dir`**, **`communications_dir`**, **`status_file`**. Use these paths for Tana, Granola, Zoom, and Phase 1b — do not assume a single legacy folder name.
3. If the user did not specify a slug and intent is ambiguous, ask once which engagement row applies.

## Preconditions

1. **`.context/conventions.md` exists** — defines umbrella keys when used (`incoming_dir`, `routing_log`, …), default engagement hint, Tana/Granola/Zoom defaults, and participant/title filters.
2. **Optional:** **`.context/engagements.md`** — per-slug paths override or specialize the defaults for mirrors and Phase 1b inboxes.
3. **MCPs** — **Tana**, Granola, and Zoom configured in the project (server names vary; confirm via `.cursor/mcp.json` or MCP picker — e.g. Tana may be `tana` / `user-tana`, Granola may be `user-granola` or `plugin-granola-granola`).
4. **Auth** — On MCP auth errors, stop and ask the user (see project `AGENTS.md` if present). Tana uses OAuth at `https://home.tana.inc/mcp` ([MCP docs](https://tana.inc/learn/features/mcp)).

## Phase 1 — Ingest

### Bits-first policy (always)

Minimize MCP and network exposure: **collect raw artifacts first**, organize second, synthesize last.

1. **Phase 1-local** — copy from `~/Documents/Zoom/` and other on-disk drops (**no network**).
2. **Phase 1-mcp** — **one batch pass** per source: discover → download full payloads → write under **`raw/`** only.
3. **Phase 2** — index, `metadata.json`, `notes_info.md`, `sync_manifest.json`, transcript stubs (**no MCP**).
4. **Phase 3** — human digest + **`context-engineering`** (bracketing, grounding, `.context/`).

**Rules:**

- Do **not** run synthesis, engagement bracketing, or `.context/` edits until **`sync_manifest.json`** lists what landed.
- **One MCP batch per source:** Zoom list + download; Granola list + `get_meetings` + transcript; Tana `listEvents` + `readEvent` + `readFullTranscript` + **`readItems` / `getItemInfo` / `listEdges` debug bundle** for every meeting-linked URI.
- **Defer** to Phase 3 unless the user asks: `query_granola_meetings`, Tana `contextRetrieval`, Tana `semanticSearchItems`.
- **Idempotent re-runs:** read manifest `gaps[]`; only re-call MCP for missing sources.

### Phase 1-local — Zoom on disk (standard, no network)

Run **before** Phase 1-mcp whenever `zoom_local_root` is set in conventions (default `~/Documents/Zoom/`).

| Step | Action |
|------|--------|
| 1 | Read **`zoom_local_root`** and optional **`zoom_local_glob`** from **`.context/conventions.md`**. |
| 2 | Match folder by **date** (`YYYY-MM-DD` in folder name) + **`title_filters`** (Tim, Reily, 1-hour, …) **or** explicit user path. |
| 3 | Copy **text only**: `meeting_saved_closed_caption.txt`, `meeting_saved_new_chat.txt`, `*.vtt` if present — **never** video/audio. |
| 4 | Write to **`raw/zoom_local/`** inside the unified mirror; record source path in **`sync_manifest.json`**. |
| 5 | If no local folder: log gap in manifest; continue to Zoom MCP. |

Also copy engagement-scoped **incoming drops** (`.md`, `.txt`) to **`raw/incoming/`** when present.

### Phase 1a — Umbrella triage (optional)

If the user says **"process incoming"** without naming an engagement **and** files sit in repo-root **`incoming/`** (see `incoming_dir` / `routing_log` in conventions), run **`process-umbrella-incoming`** first to classify, route, and append **`routing_log`**. Then continue with Phase 1b on the resolved **`engagement_incoming_dir`**.

### Phase Backfill — light mirrors and honesty

1. If a Granola folder is missing **`private_notes.md`**, **`ai_summary.md`**, or **`transcript_granola.txt`**, treat it as a **light mirror**: re-pull via `get_meetings` + `get_meeting_transcript` when MCP is available.
2. If a Tana mirror folder is missing **`tana_event.json`**, **`tana_summary.md`**, **`transcript_tana.txt`**, or **`raw/tana/debug/_index.json`**, re-pull via `readEvent` + transcript + **debug bundle** tools when MCP is available.
3. When MCP, Zoom retention, Tana event access, or local originals are missing, update **`.context/backfill-status.md`** — do not fabricate transcripts.

### Tana (context graph + native meetings)

[Tana MCP](https://tana.inc/learn/features/mcp) exposes the workspace context graph and meeting records to external agents (Cursor, Claude Code, etc.). Use it when the meeting was captured **in Tana** (native call or external-meeting agent), when the user pastes a **Tana event URL**, or when you need **cross-meeting context** (decisions, tasks, artifacts) that Granola/Zoom do not hold.

**Server:** `https://home.tana.inc/mcp` (OAuth; no API keys). In Cursor, confirm the enabled server name in MCP settings (often `tana` or `user-tana`).

**Writes are proposals, not direct commits.** Tana write tools (`createItems`, `updateItems`, …) return a **`sessionUri`**; changes land only after **`listProposals`** → user review → **`approveProposals`** (same model as Tana's built-in AI). **meeting-sync ingest is read-first** — mirror to the repo; only push writes back to Tana when the user explicitly asks.

#### Discovery (find the meeting)

Use **one** of these paths (prefer the most specific input the user gave):

1. **User pasted a Tana URL** — extract the bare event URI. Browser URLs look like `https://home.tana.inc/o/<org>/e/tana%3Aevent%3A<id>` → URL-decode to `tana:event:<id>`.
2. **`listEvents`** — `startDate` / `endDate` (`YYYY-MM-DD`), `timezone` from conventions or user, optional `query` (title substring). Filter results with **`title_filters`** / engagement scope (same spirit as Granola). Exclude upcoming events when the user asked for meetings that already happened (use status prefix in the time field).
3. **`searchItems`** — batch queries; target `{ "target": "event", "eventStartTimeMin": …, "eventStartTimeMax": … }` for calendar-window search; use `queries` for attendee names/emails from calendar metadata.

Capture **`eventUri`** (`tana:event:…`) as the canonical id. Record **`callUri`** and **`transcriptUri`** from `readEvent` (same ULID suffix).

#### Read payload (required for every Tana touch)

1. **`readEvent`** with `eventUri` — **one call** for meeting metadata:
   - title, time, attendees, participants, organizer, **tagline**, **summary**
   - companion URIs: `agendaUri`, `callUri`, `transcriptUri`, `chatUri`
   - `screenshots` (wrap-up grid), `pinnedItems`, **`relatedDocs`** (recap, storyboard, slides, chats, etc.)
2. **Transcript** (when `callUri` / `transcriptUri` exist):
   - **Default for ingest:** persist **verbatim** transcript to **`transcript_tana.txt`** via **`readFullTranscript`** with `id: callUri` (or `eventUri` — resolves automatically). Format: `[Ns] speaker: text` lines.
   - **Prefer `readTranscript` with a `task`** when the tool is available and you only need scoped excerpts for synthesis (cheaper; do not substitute for the verbatim mirror file).
   - Optional `startSec` / `endSec` for partial reads; cite moments as `[mm:ss](tana:call:…)` per tool docs.
3. **`readItems`** on selected **`relatedDocs`** URIs — at minimum any **recap / meeting-notes / artifact** docs. Use `task` for targeted extraction; omit `task` when mirroring full recap text to **`tana_artifacts/`** or **`tana_recap.md`**.
4. **`readScreenShareScreenshots`** when screen share content matters (UI demos, maps, decks). Persist **`tana_screenshots.json`** (metadata + `details` text; image pixels are not returned by MCP).
5. **Tana debug bundle (required)** — for **every** document URI tied to the meeting (`eventUri`, each **`relatedDocs`** entry, each **`pinnedItems`** entry, and companion URIs when readable), run the **debug bundle** below and persist under **`raw/tana/debug/<uri_slug>/`**. See **Appendix F** for UI-panel → MCP mapping and gaps.
6. **Optional cross-meeting context:** **`contextRetrieval`** or **`searchItems`** / **`semanticSearchItems`** with project-scoped query + optional `space` from conventions — for decisions/tasks already in the graph; link URIs in the meeting digest, do not duplicate the whole graph.

#### Tana debug bundle (always — per document URI)

The Tana web UI exposes an inspector sidebar (Table of Contents, Backlinks, Changes, Debug, Graph Node, Graph, Diff, Content (ProseMirror), State, Text Deltas, Activity, Changes (raw), Metadata, Markdown, Change Summary). **Meeting-sync must mirror everything the MCP can return** for each meeting-linked URI; record gaps in **`sync_manifest.json`** and **`notes_info.md`**.

**URI set to bundle** (dedupe):

- `eventUri` from `readEvent`
- Every URI in **`relatedDocs`**, **`pinnedItems`**, and wrap-up **`screenshots`** (when resolvable)
- Companion URIs when not redundant: `agendaUri`, `callUri`, `transcriptUri`, `chatUri` (skip if already captured as transcript/screenshots)

**`<uri_slug>`** = last path segment of the URI (e.g. `01kv97gq983ae55xgj2jm6njg8` from `tana:text:01kv97gq983ae55xgj2jm6njg8`).

| Mirror file | MCP call | Maps to UI panel(s) |
|-------------|----------|---------------------|
| **`item_info.json`** | **`getItemInfo`** `{ ids: [uri] }` | **Metadata**, partial **State** (access, owner, timestamps, proposal state, external IDs) |
| **`backlinks_incoming.json`** | **`listEdges`** `{ nodeIds: [uri], direction: "incoming", limit: 200 }` | **Backlinks** |
| **`backlinks_outgoing.json`** | **`listEdges`** `{ nodeIds: [uri], direction: "outgoing", limit: 200 }` | Outbound links (Graph edges out) |
| **`graph_edges_both.json`** | **`listEdges`** `{ nodeIds: [uri], direction: "both", limit: 200 }` | **Graph** (relationship data; not the visual layout) |
| **`content.json`** | **`readItems`** `{ ids: [uri] }` — **no `task`** | **Markdown** (body), fields, block structure, `artifactData` for artifacts |
| **`prosemirror.json`** | **`readItems`** `{ ids: [uri], forEditing: true }` | **Content (ProseMirror)** (`editableBlocks` tree) |
| **`table_of_contents.md`** | **Derived** from `prosemirror.json` or heading lines in `content.json` | **Table of Contents** (best-effort; no dedicated MCP export) |
| **`table.json`** | **`readTable`** when `content.json` shows a `table` block | Tabular docs only |
| **`debug_uri.txt`** | **Derived** — single line: canonical URI (+ title from `item_info` or `readItems`) | **Debug** (URI line only; internal debug JSON is UI-only) |

**Batching:** `getItemInfo` accepts up to **200** ids — batch all meeting URIs in one call when possible, then split responses into per-URI folders. `readItems` may be batched per tool limits; **never** pass `task` on ingest mirror passes.

**Index file:** write **`raw/tana/debug/_index.json`** listing every URI bundled, tool calls made, and per-URI status (`ok` | `unsupportedType` | `notFound` | `gap`).

**Official MCP reference:** [Tana MCP docs](https://tana.inc/learn/features/mcp) — tool list is authoritative; schemas via MCP `tools/list`.

#### Persist to mirror (Phase 1-mcp → `raw/tana/`)

When **`mirror_layout: unified_raw`** (recommended), write Tana payloads under **`raw/tana/`** inside the unified meeting folder (see **Unified mirror layout** below). Legacy flat layout may keep files at mirror root — document in **`notes_info.md`**.

| File (under `raw/tana/` or mirror root) | Source |
|------|--------|
| **`tana_event.json`** | Core `readEvent` fields + companion URIs + `relatedDocs` index |
| **`tana_summary.md`** | `tagline` + `summary` (+ optional recap excerpt) |
| **`transcript_tana.txt`** | `readFullTranscript` verbatim |
| **`tana_screenshots.json`** | `readScreenShareScreenshots` when used |
| **`tana_artifacts/`** or **`tana_recap.md`** | `readItems` on key `relatedDocs` (promoted excerpts; full bodies also in **`debug/`**) |
| **`debug/<uri_slug>/`** | **Debug bundle** per URI — see table above + **`debug/_index.json`** |

**Multi-source meetings:** Many sessions exist in **Tana + Granola + Zoom** (e.g. Zoom call with Granola notes). Ingest **all available sources**; in **`notes_info.md`** and the human digest, declare precedence (typical: **Zoom VTT** = diarized quotes; **Tana** = outcomes/artifacts/graph links; **Granola** = private notes + AAv0 summary). Bracket multi-project calls to the engagement slug in digests only — keep full payloads in mirrors.

**Not in Tana MCP (document in `notes_info.md` + `sync_manifest.json` gaps[]):**

| UI inspector panel | MCP status |
|--------------------|------------|
| **Changes**, **Changes (raw)**, **Activity** | **Not exposed** — edit-history / activity stream is UI-only |
| **Text Deltas** | **Not exposed** — internal CRDT delta log |
| **Diff** | **Not exposed** |
| **Graph Node** (internal node JSON blob) | **Not exposed** as a dedicated export; closest: **`getItemInfo`** + **`listEdges`** |
| **Change Summary** (+ **Empty** / **Latest** compare) | **Not exposed** — UI “Generate Summary” over edit history |
| **Debug** (full internal debug payload) | **Partial** — canonical URI in mirror; no server-side debug JSON |
| **Table of Contents** | **Derived** — extract headings from **`prosemirror.json`** / **`content.json`**; no native export |
| Wrap-up / screen-share **image pixels** | **Not returned** — metadata + text descriptions only |
| **`tana:canvas:`**, **`tana:user-profile:`**, some other kinds | **`readItems` → `unsupportedType`** — store URI in **`debug/_index.json`**, link only |

Also: **`listProposals`** / proposal sessions apply to **write** flows only — not part of read-first ingest unless the user explicitly mirrored a pending write session.

### Granola (always pull the **full** text payload)

`get_meeting_transcript` alone is **not** enough. Granola’s **private note body** (outlines, AI-filled sections, coaching prompts, long-form recaps) and the **AI-generated meeting summary** come from **`get_meetings`**, not from the transcript call. **Every** meeting-sync that touches Granola must persist **all** of the following that the MCP returns (unless the project’s `conventions.md` renames files — same required *content*, different filenames allowed).

1. `list_meetings` with `time_range: custom` and `custom_start` / `custom_end` bracketing target day(s).
2. Identify rows by title/id per **conventions** (e.g. filter by project title substring); capture **`meeting_id`** (UUID).
3. **`get_meetings`** with `meeting_ids` (batch ≤10):
   - Persist **`private_notes`** to **`raw/granola/private_notes.md`** (full markdown/note body — matches Granola web UI).
   - Persist **`summary`** to **`raw/granola/ai_summary.md`**.
4. **`get_meeting_transcript`** with `meeting_id`:
   - Persist to **`raw/granola/transcript_granola.txt`** (Me/Them or narrative stream).
5. **Phase 2 only:** promote copies or symlinks to mirror-root `private_notes.md` / `ai_summary.md` / `transcript_granola.txt` if the project expects legacy flat names — **`raw/granola/`** stays the immutable source.
6. **Canonical `transcript.txt`:** set in Phase 2 from best available diarized source (Zoom cloud VTT > local CC > Tana > Granola). Document in **`notes_info.md`**.
7. **`query_granola_meetings`:** Phase 3 only unless user asks.

**Not available via Granola MCP (document in `notes_info.md`):** embedded **screenshot images** or other binaries shown in the Granola web UI are typically **not** returned by MCP tools. If the team needs screenshots in-repo, export them manually from Granola into e.g. `<mirror_folder>/screenshots/` and reference paths in **`notes_info.md`**.

### Zoom (cloud) — Phase 1-mcp

Run **after Phase 1-local** (local copy is faster and has no network dependency).

1. Resolve `user_id` from **conventions** (email or Zoom user id).
2. `list_recordings` with `from` / `to` (`yyyy-MM-dd`), paginate with `next_page_token` if needed.
3. For each relevant recording: `download_cloud_recording_file` (or `get_meeting_recordings` + download) for **text only** — `audio_transcript.vtt`, chat `.txt` — into **`raw/zoom_cloud/`**. **Never** commit share/play URLs with embedded tokens.
4. Log gaps in **`sync_manifest.json`** when cloud transcript is missing but local CC exists.

### Git (each upstream clone listed in conventions)

1. Prefer work on a local branch; align with project `AGENTS.md` for pull/rebase policy.
2. If **Git LFS smudge** fails (404): `GIT_LFS_SKIP_SMUDGE=1 git pull` and **record** pointer-only paths in notes or synthesis (do not claim full data for those paths).
3. If dirty tree blocks pull: stash → pull → pop (get user permission for anything destructive).

### Optional documents

- **Figures from .docx:** e.g. `unzip -j -o "file.docx" "word/media/*" -d <assets_dir>/` using path from conventions or docs layout.

### Phase 1b — Local incoming (email and attachments)

Use when the user drops **saved MIME threads** (`.eml`) into the project **incoming** directory for one-off processing — **not** a mail server; this is a manual staging inbox (often **gitignored**).

1. Read **`incoming_dir`**, **`processed_dir`**, **`communications_dir`**, and **`status_file`** from the active **engagement row** in **`engagements.md`** when those keys exist; otherwise from **`.context/conventions.md`** (legacy single-inbox projects).
2. **Scan** `<repo_root>/<incoming_dir>/*.eml`** (ignore `processed/` subfolders).
3. **For each `.eml` not yet summarized** in `communications/` (check for a provenance line pointing at that filename, or compare dates/subjects):
   - Parse MIME with Python **`email`** stdlib (or equivalent): `Date`, `From`, `To`, `Cc`, `Subject`, and a **short body summary** (prefer plain text part; truncate long HTML to a structured summary).
   - Create **`communications_dir`** markdown per repo’s comms README: `YYYY-MM-DD-NNN-short-description.md` with YAML metadata (`id`, `date`, `type: email`, `direction`, `subject`, `thread`, `status`, `next-action`, etc.).
   - Add a provenance line: **`Source: incoming/<filename>.eml`** (local only; file stays out of git if `incoming/` is ignored).
   - **Privacy:** do not paste full sensitive threads into committed files if policy requires; use redacted summary + pointer to local `.eml`.
4. **Update** **`status_file`** (open threads, waiting-on, next action, COMMS IDs).
5. **Refile:** after comms + status are updated, **move** the `.eml` to `<incoming_dir>/processed/YYYY-MM/` (create directories as needed). Default is **move** (preserves local audit trail); delete only if the user prefers.
6. If an `.eml` was **already** captured in an existing comms file (same thread, earlier save), only **move** it to `processed/` — do not duplicate the markdown.

**Outputs checklist (Phase 1b)**

- [ ] Incoming directory scanned (`*.eml`)
- [ ] New comms filed (or skipped as duplicate) per project naming/metadata
- [ ] `STATUS` / dashboard updated
- [ ] `.eml` moved to `incoming/processed/YYYY-MM/` (or explicitly left in place if blocked)

Then run **`context-engineering`** for synthesis and `.context/` updates.

## Phase 2 — Index and store (no MCP)

**Prerequisite:** **`raw/`** populated and **`sync_manifest.json`** written. No synthesis or `.context/` edits in this phase.

### Unified mirror layout (`mirror_layout: unified_raw`)

Default when conventions set **`mirror_layout: unified_raw`** (Tana co-located with Granola):

```
<granola_root>/<namespace>/<meetingId>_<SanitizedTitle>_<YYYY-MM-DD>/
  raw/
    zoom_local/       # Phase 1-local copies
    zoom_cloud/       # Phase 1-mcp VTT + chat
    granola/          # private_notes.md, ai_summary.md, transcript_granola.txt
    tana/             # tana_event.json, tana_summary.md, transcript_tana.txt, debug/<uri_slug>/, artifacts/
    incoming/         # operator drops (.md notes)
  transcript.txt      # canonical diarized (Phase 2: cloud VTT > local CC > Tana > Granola)
  notes_info.md
  sync_manifest.json
  metadata.json
```

**`raw/` is immutable** — promoted/normalized files at mirror root may duplicate pointers but must not replace raw copies.

Legacy split layout (`zoom-transcripts/` + flat granola folder) remains supported when conventions omit `unified_raw`.

1. **Unified / Granola mirror:** `<granola_root>/<namespace>/<uuid-prefix>_<SanitizedTitle>_<MonDDYYYY>/` with:
   - **`private_notes.md`** — full note body from **`get_meetings`** (required).
   - **`ai_summary.md`** — AI summary / structured recap from **`get_meetings`** (required).
   - **`transcript_granola.txt`** — verbatim stream from **`get_meeting_transcript`** (required).
   - **`transcript.txt`** — project’s canonical readable/diarized transcript when sourced elsewhere (e.g. Zoom `audio_transcript` VTT, or Tana `readFullTranscript` when Tana is canonical); if Granola is the only ASR source, conventions may map `transcript.txt` to Granola-only — state clearly in **`notes_info.md`**.
   - **`metadata.json`** — id, title, date, participants, Granola/Tana URLs, provenance, mirror artifact list.
   - **`notes_info.md`** — web URLs, which transcript is canonical for quotes, MCP limits (screenshots).
   - **`sync_manifest.json`** — recommended ingest manifest (tools + files + time).
   - **Optional Tana co-mirror files** in the same folder when the meeting exists in Tana — see Tana table above (`tana_event.json`, `tana_summary.md`, `transcript_tana.txt`, …).
2. **Tana-only mirror** (when no Granola row exists): same folder template under **`<tana_mirror>/`** with Tana-required files + optional Zoom `transcript.txt`.
3. **Zoom mirror:** `<transcripts_root>/<YYYY-MM-DD>_<Title>/` with `audio_transcript.vtt` (or `transcript.VTT`), `closed_caption.VTT`, `chat.TXT` as obtained.
4. Update **`index.json`** under each mirrored tree (append meeting object; bump `last_curated_at` / `curated_at`). Include **`tana_event_uri`** when present.
5. **`notes/<YYYY-MM-DD>-<project>-transcript.md`:** stub — **links** to `raw/*` paths + promoted files; **do not** paste full transcript.
6. **`notes/<YYYY-MM-DD>-<project>-notes.md`:** human digest — **Phase 3** (`context-engineering`), not Phase 2.

## Outputs checklist

### Phase 1 (bits first)

- [ ] **Phase 1-local:** `raw/zoom_local/` (+ `raw/incoming/` drops) copied; gaps in manifest
- [ ] **Phase 1-mcp:** `raw/zoom_cloud/`, `raw/granola/`, `raw/tana/` populated in **one batch**; **`raw/tana/debug/`** bundle for every meeting-linked URI; proposals **not** auto-approved
- [ ] **`sync_manifest.json`** lists every file + `gaps[]` before any digest

### Phase 2 (organize only)

- [ ] **`transcript.txt`** + **`notes_info.md`** + **`metadata.json`** at mirror root
- [ ] **`index.json`** files updated (granola + zoom indices per conventions)
- [ ] Transcript **stub** only (`meeting-notes-*-transcript.md`) — links, no full paste

### Phase 3 (synthesis — `context-engineering`)

- [ ] **`meeting-notes-*-notes.md`** digest with engagement bracket + grounding table
- [ ] `.context/` pillar updates

### Other phases

- [ ] **Phase 1a (if umbrella triage):** `routing_log` updated; items routed or staged in `opportunities/`; root **`README.md`** **`## Workspace activity`** — **Umbrella incoming** row + **`Repo last update`** (see **`.context/conventions.md`**)
- [ ] **Phase Backfill:** light mirrors upgraded or gaps in **`backfill-status.md`**
- [ ] **Phase 1b (if incoming used):** `.eml` scanned; comms filed; status updated
- [ ] Root **`README.md`** — **`## Workspace activity`**: refresh rows for **each engagement** touched + **`Repo last update`** when mirrors, comms, or status changed (see **`.context/conventions.md`** *Workspace activity*)

## After ingest

- **Synthesis, PROGRESS/CAPSTONE edits, grounding tables, and `.context/` pillar updates** → use **`context-engineering`** (Phases 3–4 / feed-forward), not this skill.
- **Umbrella repos:** if **`README.md`** has **`## Workspace activity`**, update **Last activity** + **Status** for **each engagement slug** this run touched (Tana / Granola / Zoom / comms / `STATUS.md` / `index.json` under that slug) using **`git log`** rules in **`.context/conventions.md`**; set **`Repo last update:`** to **today** when any engagement row or mirror subtree changed materially.

---

## Appendix A — Optional segment tagging (DEEPLISTEN)

When classifying transcript snippets or notes for traceability, you may tag segments with one of:

| Tag | Use |
|-----|-----|
| **edit directive** | Change a doc, figure, or dataset |
| **substantive feedback** | Corrects or adds domain content |
| **contextual discussion** | Background, not a decision |
| **meta-observation** | Process, norms, facilitation |
| **action item** | Owner + deliverable |
| **question** | Open or resolved |

This is **optional** — no automation required.

---

## Appendix B — Optional facilitation frame (PALEO)

For structured live sessions or retro notes:

- **P**urpose — why meet
- **A**genda — topics / timeboxes
- **L**ogistics — tools, recording consent, attendees, links
- **E**mpathy — equity of voice; who needs to be heard
- **O**utcomes — decisions, owners, artifacts

Adjust wording to match your team’s facilitation docs if they define PALEO differently.

---

## Appendix C — Granola MCP → mirror files (reference)

| Source | Typical mirror file | Notes |
|--------|---------------------|--------|
| `get_meetings` → `private_notes` | `private_notes.md` | Long-form note; matches web UI body when present. |
| `get_meetings` → `summary` (and related) | `ai_summary.md` | AI recap / bullets / actions when returned. |
| `get_meeting_transcript` | `transcript_granola.txt` | Granola-native ASR stream; parallel to Zoom/Tana ASR if both exist. |
| Tana `readFullTranscript` | `transcript_tana.txt` | Speaker-attributed; parallel to Zoom/Granola. |
| Zoom `audio_transcript` etc. | `transcript.txt` | Often canonical diarized quotes — declare in `notes_info.md`. |
| Combined provenance | `metadata.json`, `sync_manifest.json`, `notes_info.md` | URLs, limits (screenshots), which transcript is canonical. |

Projects may rename files via `.context/conventions.md` but must preserve the **same five text artifacts** for Granola mirrors: private notes body, AI summary, Granola transcript, canonical readable transcript policy, and provenance bundle. When Tana is in scope, add **`tana_event.json`**, **`tana_summary.md`**, and **`transcript_tana.txt`** (or document why a source was unavailable).

## Appendix D — Tana MCP → mirror files (reference)

| Tool | Typical mirror / use | Notes |
|------|----------------------|--------|
| `listEvents` / `searchItems` (event target) | discovery only | Bracket by engagement `title_filters`; capture `eventUri`. |
| `readEvent` | `tana_event.json`, `tana_summary.md` | Tagline, summary, `relatedDocs`, companion URIs. |
| `readFullTranscript` | `transcript_tana.txt` | Verbatim `[Ns] speaker: text`; prefer for mirrors. |
| `readTranscript` (+ `task`) | synthesis only | Cheaper excerpt; not a substitute for verbatim mirror. |
| `readItems` | `tana_recap.md`, `tana_artifacts/*`, **`debug/<slug>/content.json`** | Recaps, typed outcomes, artifacts from `relatedDocs`; **no `task`** on ingest. |
| `readItems` (`forEditing: true`) | **`debug/<slug>/prosemirror.json`** | ProseMirror-style `editableBlocks`. |
| `getItemInfo` | **`debug/<slug>/item_info.json`** | Metadata / partial state. |
| `listEdges` | **`debug/<slug>/backlinks_*.json`**, **`graph_edges_both.json`** | Backlinks + graph relationships. |
| `readTable` | **`debug/<slug>/table.json`** | When doc contains a table. |
| `readScreenShareScreenshots` | `tana_screenshots.json` | Text descriptions only; no image bytes. |
| `contextRetrieval` / `semanticSearchItems` | digest links only | Cross-meeting graph context; cite `tana:text:…` URIs. |
| `createItems` / `updateItems` + `listProposals` | optional write-back | Ingest skill does **not** auto-approve; user reviews in Tana. |

## Appendix F — Tana UI inspector → MCP availability (reference)

Panels visible in the Tana document sidebar (screenshots / debug drawer) vs what **meeting-sync** can mirror:

| UI panel | Available via MCP? | Ingest action |
|----------|-------------------|---------------|
| **Table of Contents** | Partial | Derive **`table_of_contents.md`** from headings in **`prosemirror.json`** / **`content.json`** |
| **Backlinks** | Yes | **`listEdges`** incoming → **`backlinks_incoming.json`** |
| **Changes** | **No** | Log gap; UI edit feed not in [official tool list](https://tana.inc/learn/features/mcp) |
| **Debug** | Partial | Write **`debug_uri.txt`** (URI + title); full internal debug JSON is UI-only |
| **Graph Node** | **No** (dedicated) | Use **`getItemInfo`** + **`listEdges`** as substitute |
| **Graph** | Partial | **`graph_edges_both.json`** (edges, not visual layout) |
| **Diff** | **No** | Log gap |
| **Content (ProseMirror)** | Yes | **`readItems` `forEditing: true`** → **`prosemirror.json`** |
| **State** | Partial | **`getItemInfo`** (access, proposal state, timestamps) |
| **Text Deltas** | **No** | Log gap |
| **Activity** | **No** | Log gap |
| **Changes (raw)** | **No** | Log gap |
| **Metadata** | Yes | **`getItemInfo`** → **`item_info.json`** |
| **Markdown** | Yes | **`readItems`** (no task) → **`content.json`** body |
| **Change Summary** | **No** | UI generator over edit history; **Empty** / **Latest** compare not in MCP |

When Tana adds MCP tools for edit history or diffs, extend this table and the debug bundle file list — re-check **`tools/list`** on the server after MCP updates.

**Convention keys** (add to project `conventions.md` when Tana is used):

- **`mcp_server_tana`:** `tana` (or resolved Cursor server id)
- **`tana_mirror`:** e.g. `01-background/tana-mirror/` (optional; may co-locate with `granola-mirror`)
- **`tana_space`:** optional `tana:space:…` URI to scope search
- **`tana_title_filters`:** reuse or extend Granola `title_filters`
- **`zoom_local_root`:** `~/Documents/Zoom/` (default)
- **`zoom_local_glob`:** `*/meeting_saved_*.txt`
- **`mirror_layout`:** `unified_raw` (recommended) or legacy split

## Appendix E — Local Zoom → `raw/zoom_local/` (reference)

| Source file | Mirror path |
|-------------|-------------|
| `meeting_saved_closed_caption.txt` | `raw/zoom_local/meeting_saved_closed_caption.txt` |
| `meeting_saved_new_chat.txt` | `raw/zoom_local/meeting_saved_new_chat.txt` |
| `*.vtt` (if saved locally) | `raw/zoom_local/<filename>.vtt` |

Match folder: `~/Documents/Zoom/<YYYY-MM-DD> … <title>/`.

## Automation (`just` + CLIs)

- After ingest, suggest **`just`** at repo root (read-only snapshot: git, `incoming/` files, `ROUTING-LOG` excerpt, `README` workspace activity). See repo **`docs/AUTOMATION.md`**.
- **MCP** (Tana, Granola, Zoom) stays on the **Cursor IDE** host for slash skills; `just` does not load MCP. For headless parity, use **`cursor-agent`** with **`--print --mode plan`** and an explicit read-only prompt, or run the same skill manually in Cursor.

## See also

- **`context-engineering`** — three pillars, `.context/` lifecycle, bootstrap, synthesis, grounding.
- Project **`PROVENANCE.md`** — how transcripts and upstream data were obtained.
