# dotfiles-cursor-compendium (scaffold)

**This machine:** live repo at `/Users/me/src/dotfiles-cursor-compendium` (private GitHub: `aculich/dotfiles-cursor-compendium`). Canonical notes: [`docs/COMPENDIUM.md`](../docs/COMPENDIUM.md).

This directory is a **portable scaffold** for a **sibling private git repository** that aggregates:

- Mirrored project `.cursor/` and optional `.specstory/`
- Copies of **global** plans (`~/.cursor/plans`) and **per-project** `.cursor/plans`
- **`skills-registry/`** manifests (vendor vs authored vs project-index)

## Bootstrap

1. Copy this entire `compendium/` tree to a new path (e.g. `~/src/dotfiles-cursor-compendium`).
2. `cd` there, `git init`, create a **private** remote (`gh repo create ... --private --source=. --push`).
3. Set **`export CURSOR_COMPENDIUM_ROOT`** to that directory in your shell profile (or use absolute paths in `launchd`).
4. Edit `skills-registry/*.yaml` from the examples; add project roots to `project-index.yaml`.
5. Run `scripts/snapshot-all.sh` (dry review) then commit.

**Source of truth:** Document per artifact whether you edit in the **product repo**, **`~/.cursor`**, or **only** in this compendium. The compendium is primarily a **backup and index**, not a second place to hand-edit product code unless you adopt an explicit sync-back workflow.

## Privacy

May contain **MCP configs**, **chat-adjacent** SpecStory data, and **internal** plans. Keep the GitHub repo **private**. Snapshot scripts exclude common secret filenames—extend the denylist before mirroring a new project class.

## Automation

See `launchd/` for an optional **daily** snapshot + commit example. Default posture: **compendium repo only**—do not point automation at `dotfiles/cursor` unless you deliberately opt in.
