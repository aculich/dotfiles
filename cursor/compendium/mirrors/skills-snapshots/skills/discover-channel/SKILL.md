---
name: discover-channel
description: >-
  Classifies pasted URLs as collaboration channels vs ephemeral cites, probes
  MCP/integrations, registers .context/datasources.md, then hands off ingest
  (e.g. meeting-sync for Granola). Use when a collaborator pastes a Granola,
  Zoom, Tana, or other capture-link and the repo should discover how to pull it.
disable-model-invocation: true
---

# Discover channel (by reference)

When someone pastes a URL into this collab, **do not invent a one-off scraper**. Discover whether it is a **channel** (recurring capture of our exchanges) or **ephemeral** (cite once). Probe MCP first; register once; routinize after.

## Preconditions

1. Read `.context/datasources.md` (create from [reference.md](reference.md) schema if missing).
2. Read `.context/conventions.md`.
3. Prefer in-repo skill; meeting ingest engine remains global **`meeting-sync`** unless conventions say otherwise.

## Classify

| Class | Heuristics | Action |
|-------|------------|--------|
| **Channel** | Host matches known provider (`notes.granola.ai`, Zoom recording/docs, `home.tana.inc` events); user says “channel / source / fold into repo”; URL is under a conventions folder URL | Probe → register if new → ingest |
| **Ephemeral** | One-off article, marketing page, unrelated GitHub issue; no “remember this” language | Cite in `notes/` or `incoming/` only — **do not** add to datasources |
| **Ambiguous** | Unclear | Ask once: “Register as a collaboration channel, or just cite once?” |

## Checklist

```
- [ ] Extract URL(s) and meeting/event ids from paste
- [ ] Classify channel vs ephemeral (or ask)
- [ ] Lookup datasources.md + conventions.md
- [ ] MCP probe (GetMcpTools) before any custom fetch
- [ ] Known channel → hand off ingest_skill
- [ ] New channel → dry-run registration; apply only on approve / "register this channel"
- [ ] Emit MCP health report (server, status, tools, gaps)
- [ ] Update last_ingested / index.json after successful ingest
```

## MCP probe

1. Resolve `mcp_server` from matching datasource row, or from **Host → adapter** table in [reference.md](reference.md).
2. Call **GetMcpTools** for that server.
3. Report: `serverStatus` (`ready` / `needsAuth` / missing), tools present, gaps.
4. If `needsAuth`, stop and ask human to auth — do not fake payloads.

## Known channel → ingest

For **granola-ezw** (and future Granola rows):

1. Parse meeting UUID from `https://notes.granola.ai/t/<uuid>…`
2. Skip if `index.json` already lists that id (unless user asks refresh).
3. Hand off to **`meeting-sync`** Phases 1–2 into `mirror_root` (`granola/EZW/`):
   - `get_meetings` → `raw/granola/private_notes.md`, `raw/granola/ai_summary.md`
   - `get_meeting_transcript` → `raw/granola/transcript_granola.txt` (+ promote `transcript.txt`)
   - Write `metadata.json`, `notes_info.md`, `sync_manifest.json`
   - Append `index.json`; stub `notes/<date>-ezw-*.md` as links only
4. Phase 3 / **`context-engineering`** only when user asks for digest / `.context/` pillar updates.
5. Bump `last_ingested` on the datasource section.

## New channel → register (dry-run then apply)

Propose (prefix `[plan]` until approved):

- New row in `datasources.md`
- Optional conventions keys (`mcp_server`, `mirror_root`, …)
- First mirror path under repo

Apply on: `register this channel` / `approve` / `bootstrap apply` / same-message `go ahead` with register intent.

## Out of scope

- Rewriting global `meeting-sync`
- Auto-registering every pasted URL
- Deep Zoom/Tana adapters beyond probe + register stub (see reference)

## See also

- [reference.md](reference.md) — host adapters, datasources schema, health report shape
- Skills: `meeting-sync`, `context-engineering`, `bootstrap-collaborator`
