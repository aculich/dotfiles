# discover-channel — reference

## Host → adapter

| Host pattern | Default mcp_server | Default ingest_skill | Notes |
|--------------|--------------------|----------------------|-------|
| `notes.granola.ai` | `plugin-granola-granola` | `meeting-sync` | Meeting UUID in path `/t/<uuid>` |
| `zoom.us` / `docs.zoom.us` | `user-zoom` / `user-zoom-official` | `meeting-sync` | Probe both; register stub if new |
| `home.tana.inc` | `user-tana` | `meeting-sync` | Event URIs; register stub if new |
| other | (none) | — | Ephemeral unless human says channel |

Override with `.context/datasources.md` when a row exists.

## datasources.md schema

```markdown
# Collaboration datasources

| id | kind | host_pattern | status | mcp_server | ingest_skill | mirror_root | notes |
|----|------|--------------|--------|------------|--------------|-------------|-------|
| granola-ezw | channel | notes.granola.ai | active | plugin-granola-granola | meeting-sync | granola/EZW/ | folder EZW |

## granola-ezw

- folder_id / folder_url from conventions
- first_seen / last_ingested
- how_to_check_mcp: GetMcpTools server plugin-granola-granola; expect ready
```

`kind` is `channel` only for routinized capture. Do not invent other kinds without human approval.

## MCP health report (emit every run)

```markdown
### MCP health
- server: <id>
- status: ready | needsAuth | missing
- tools: <comma list or MISSING>
- gaps: <auth / missing tools / none>
```

## Granola meeting folder naming

Per conventions `folder_pattern`:

`<uuid8>_<SanitizedTitle>_<YYYY-MM-DD>/`

Example: `c97a98da_ReadingPhilosophyLearningStrategies_2026-07-14/`

Sanitize: alphanumeric only; collapse spaces; truncate reasonably.

## Registration dry-run example

```text
[plan] Add datasources row id=zoom-cloud host=zoom.us mcp=user-zoom
[plan] conventions: zoom_mirror_root=zoom/
[plan] first mirror: zoom/<meeting>/
NO FILES WRITTEN — DRY RUN ONLY
```

## Ephemeral handling

Write at most a one-line cite under `notes/` or leave in chat. Never invent MCP calls for ephemeral URLs.
