# Artifact map — workspace chat history

Where SpecStory, Chatstory, Cursor, and Claude store chat/plan artifacts.

## Survival matrix

| Store | Typical path | Survives project delete? | Default preserve action |
|-------|--------------|--------------------------|-------------------------|
| Chatstory vault partition | `~/.chatstory/nodes/<node>/providers/cursor/workspaces/{slug}__{key}/` | **Yes** | `freshen` + `pointer` |
| SpecStory (in-repo) | `{ROOT}/.specstory/` | **No** | `copy-to-pdv` |
| Cursor agent transcripts | `~/.cursor/projects/<encoded>/agent-transcripts/` | Yes (outside tree) | `copy-to-pdv` (link for later) |
| Cursor agent-tools blobs | `…/agent-tools/` | Yes | `skip` unless `--include-agent-tools` |
| Cursor canvases | `…/canvases/` | Yes | `copy-to-pdv` if present |
| Global plans | `~/.cursor/plans/*.plan.md` | Yes (global) | `copy-to-pdv` matched by slug |
| Project plans | `{ROOT}/.cursor/plans/` | **No** if under ROOT | `copy-to-pdv` |
| Claude Code projects | `~/.claude/projects/<encoded>/` | Yes (outside tree) | `copy-to-pdv` if exists |
| VS Code workspaceStorage DBs | `~/Library/Application Support/Cursor/User/workspaceStorage/<hash>/` | Yes | **out of scope** (not markdown) |

## Naming — Chatstory partition

Matches `~/projects/chatstory/src/vault/vaultPaths.ts`:

- `slug` = sanitized `basename(realpath)` — lowercase `[a-z0-9_-]`, max 48
- `workspace_key` = `sha256(realpath).hex[:16]`
- Partition dir: `{slug}__{workspace_key}`

Helper: [`scripts/resolve-partition.sh`](scripts/resolve-partition.sh).

History filenames inside the partition:

```text
YYYY-MM-DD_HH-MM-SSZ-{title_slug}.md
YYYY-MM-DD_HH-MM-SSZ-plan-{plan_slug}.plan.md
```

## Cursor project path encoding

Cursor encodes the absolute project path as a directory under `~/.cursor/projects/`:

- Strip leading `/`
- Replace `/` with `-`

Example: `/Users/me/tools/macosx-tools` → `Users-me-tools-macosx-tools`.

Also check sibling dirs for nested products (e.g. `…-apps-jumpkey`, `…-universal-inbox`).

## Claude project encoding

Claude Code uses `~/.claude/projects/` with a similar path-encoded directory. If no entry exists for ROOT, record `claude: none` in the manifest.

## SpecStory layout

```text
.specstory/
  history/*.md
  .project.json
  statistics.json
  cli/config.toml   # optional
```

Nested clones under an umbrella may each have their own `.specstory` — inventory every tree in the sweep set.

## What Chatstory does / does not capture

| Source | In Chatstory? |
|--------|---------------|
| Cursor IDE chats + plans | Yes |
| SpecStory `.specstory/history` | **No** (clean-room; inspiration only) |
| Claude / Codex / Gemini | Not yet (provider stubs) |

Therefore SpecStory **must** be copied to PDV even when a Chatstory partition exists.

## Freshen commands (extension; no headless CLI yet)

| Command id | Role |
|------------|------|
| `chatstory.saveNow` | Force capture pass |
| `chatstory.reexportHistory` | Full rewrite from Cursor DB |
| `chatstory.syncArchive` | Flush + git sync |
| `chatstory.auditWorkspace` / `verifyCapture` | Optional verify |

Follow-up product work: `chatstory archive --project <path>` headless CLI.
