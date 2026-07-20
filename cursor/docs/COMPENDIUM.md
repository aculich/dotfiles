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
cd "$CURSOR_COMPENDIUM_ROOT"
./scripts/snapshot-all.sh
git status
git commit -am 'chore(compendium): snapshot'   # when you want a manual save
git push
```

**`project-paths.txt`** is normally **regenerated** by `discover-project-paths.py`, which `snapshot-all.sh` runs first (unless `COMPENDIUM_AUTO_DISCOVER=0`). It merges paths Cursor knows from `workspaceStorage` / `globalStorage` with a scan for `.cursor/`, `.claude/`, and `.specstory/` under `~/projects`, `~/tools`, and a shallow `$HOME` pass. Orphans (on disk only) get `orphan-…` slugs; see `discover-report.json`. Copy from `project-paths.example.txt` only for a cold start. Fill **`skills-registry/*.yaml`** for vendor vs authored inventory.

Personal skill: **`~/.cursor/skills/compendium-discover-projects/SKILL.md`**

## Scheduled daily snapshot + commit

1. Copy `launchd/com.user.cursor-compendium-daily.plist.example` to `~/Library/LaunchAgents/com.user.cursor-compendium-daily.plist` (adjust label if you already use it).
2. `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.cursor-compendium-daily.plist`
3. Confirm paths inside the plist match `CURSOR_COMPENDIUM_ROOT` and that `git` in the plist environment can push (SSH or HTTPS credential helper).

The plist runs `snapshot-all.sh` (which runs **discover** then global plans then per-project snapshots), then commits only if the index changed. It does **not** auto-push by default; add `git push` to the plist command string if you want daily pushes (ensure non-interactive auth).

## Updating the scaffold in dotfiles

When you change layout or scripts under `dotfiles/cursor/compendium/`, copy or merge into the sibling repo (or maintain the sibling as the only long-term home and treat dotfiles as a template snapshot).

## Related

- Personal skill: `~/.cursor/skills/bootstrap-tool-config-repo/SKILL.md`
- Personal skill: `~/.cursor/skills/compendium-discover-projects/SKILL.md`
- [MULTIROOT-cursor-lifecycle.md](MULTIROOT-cursor-lifecycle.md) (plans paths and chat history)
