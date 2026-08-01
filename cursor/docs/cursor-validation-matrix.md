# Validation matrix (Cursor 3.13.25)

Method tags: `path` = filesystem; `sqlite` = DB open/query; `ui` = Settings screenshot; `docs` = official docs; `script` = repo script.

| Claim | Status | Method | Evidence |
|-------|--------|--------|----------|
| Release track Nightly + version 3.13.25 | confirmed | ui | About dialog → [VERSION](cursor-internals-VERSION.md) |
| Plans default under `~/.cursor/plans` | confirmed | path | 1513 `*.plan.md`; [probe](research/local-storage-probe-20260730.txt) |
| Workspace plans under `<project>/.cursor/plans` | confirmed | docs+path | [Plan Mode](https://cursor.com/docs/agent/plan-mode); [cursor-home-and-plans](cursor-home-and-plans.md) |
| No global plans DB | confirmed | docs+path | Plans are files; catalog script |
| Canvases under `~/.cursor/projects/*/canvases` | confirmed | path | 280 dirs; [catalog-cursor-canvases.sh](../scripts/catalog-cursor-canvases.sh) |
| Official docs omit managed canvas path | confirmed | docs | [canvas docs](https://cursor.com/docs/agent/tools/canvas) extract |
| `workspaceStorage/*/state.vscdb` exists | confirmed | path | 820 workspaces |
| `workspace.json` maps hash → folder URI | confirmed | path | probe samples |
| `globalStorage/state.vscdb` exists | confirmed | path | probe |
| `~/.cursor/chats/**/store.db` exists | confirmed | path | 27 files |
| Agent transcripts under projects | confirmed | path | 1643 jsonl |
| Agent = Instructions + Tools + Model | confirmed | docs | [overview](https://cursor.com/docs/agent/overview) |
| Hooks in `hooks.json` user/project | confirmed | docs+path | [hooks](https://cursor.com/docs/hooks); `~/.cursor/hooks.json` |
| Skills in `.cursor/skills` / `~/.cursor/skills` | confirmed | docs | [skills](https://cursor.com/docs/skills) |
| ItemTable composer keys | suspected | community | Forum/ChatStory; re-query after upgrades |
| cursorDiskKV bubble keys | suspected | community | ChatStory/SpecStory |
| Instant Grep local index | confirmed | ui | Indexing settings screenshot |
| Run Everything unsandboxed + MCP protection ON | confirmed | ui | Composer settings screenshots (your machine) |
| Google BYOK ON with Ultra banner | confirmed | ui | API Keys screenshot |
| tribecode Cursor support | contradicted (absent) | docs | [tribecode](https://tribecode.ai/docs) “Coming Soon” for Cursor |

## Re-validation checklist (after upgrade)

1. Update [VERSION](cursor-internals-VERSION.md) from About.
2. Re-run probe → new `research/local-storage-probe-YYYYMMDD.txt`.
3. Spot-check one `state.vscdb` key list (readonly).
4. Smoke `catalog-cursor-plans.sh` + `catalog-cursor-canvases.sh`.
5. Retest P0 CLIs (`cursor-history`, vibe-replay) against chat store.
