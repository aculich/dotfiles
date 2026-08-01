# Cursor compendium (private sibling repo)

This workspace tracks a **scaffold** under [`compendium/`](compendium/README.md). The **live** compendium git repo is a **sibling** on disk (not inside `dotfiles/cursor`), created and pushed as a **private** GitHub repository.

## Live instance

| Item | Value |
| --- | --- |
| **Path** | `/Users/me/ops/dotfiles-cursor-compendium` |
| **Remote** | [https://github.com/aculich/dotfiles-cursor-compendium](https://github.com/aculich/dotfiles-cursor-compendium) (private) |
| **Env** | `export CURSOR_COMPENDIUM_ROOT=/Users/me/ops/dotfiles-cursor-compendium` |

Add the `export` line to `~/.zshrc` (or use `direnv`) so `scripts/snapshot-all.sh` runs without extra flags.

`~/ops` is the home-level parking lot for **operational sibling repos** (backups / eval scratch)—not product source. See `~/ops/README.md`.

## Day-to-day

```bash
export CURSOR_COMPENDIUM_ROOT=/Users/me/ops/dotfiles-cursor-compendium
# From ~/dotfiles/cursor (preferred):
just compendium-backup

# Or directly:
cd "$CURSOR_COMPENDIUM_ROOT"
./scripts/snapshot-all.sh   # ends with commit-and-push.sh by default
```

`snapshot-all.sh` verifies the GitHub remote is **PRIVATE**, then commits and pushes. Skip publish with `COMPENDIUM_AUTO_PUSH=0`. Publish-only: `just compendium-push` or `./scripts/commit-and-push.sh`.

**`project-paths.txt`** is normally **regenerated** by `discover-project-paths.py`, which `snapshot-all.sh` runs first (unless `COMPENDIUM_AUTO_DISCOVER=0`). It merges paths Cursor knows from `workspaceStorage` / `globalStorage` with a scan for `.cursor/`, `.claude/`, and `.specstory/` under `~/projects`, `~/tools`, and a shallow `$HOME` pass. Orphans (on disk only) get `orphan-…` slugs; see `discover-report.json`. Copy from `project-paths.example.txt` only for a cold start. Fill **`skills-registry/*.yaml`** for vendor vs authored inventory.

Personal skill: **`~/.cursor/skills/compendium-discover-projects/SKILL.md`**

## Scheduled daily snapshot + commit + push

From `~/dotfiles/cursor`:

```bash
just install-compendium-daily    # 06:00 LaunchAgent → snapshot-all (includes push)
just compendium-daily-status
```

Or copy `launchd/com.user.cursor-compendium-daily.plist.example` manually. Logs: `/tmp/cursor-compendium-daily.log` (`.err`). Plist uses `bash -lc` so `gh`/HTTPS credentials from your login environment are available.

## Updating the scaffold in dotfiles

When you change layout or scripts under `dotfiles/cursor/compendium/`, copy or merge into the sibling repo (or maintain the sibling as the only long-term home and treat dotfiles as a template snapshot).

## Related

- Personal skill: `~/.cursor/skills/bootstrap-tool-config-repo/SKILL.md`
- Personal skill: `~/.cursor/skills/compendium-discover-projects/SKILL.md`
- [MULTIROOT-cursor-lifecycle.md](MULTIROOT-cursor-lifecycle.md) (plans paths and chat history)
- [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md) (Cloud vs local; skills SoT stays in `~/projects/agent-skills`)
