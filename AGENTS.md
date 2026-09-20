# Agent memory (continual learning)

## Learned User Preferences

- Prefer Oh My Zsh built-in plugins for shell UX when they match the need (for example grouped alias listing via the `aliases` plugin) instead of maintaining a separate custom implementation that duplicates the same command names.
- When the user attaches an implementation plan, execute all listed todos, update todo status while working, and do not edit the plan file unless they ask to change it.
- When asked to commit accumulated work, prefer splitting into sensible, reviewable chunks rather than one enormous commit.
- For new shell tools and integrations, install declared dependencies and record how to reproduce setup (keybindings, packages, extensions) in repo docs where appropriate.

## Learned Workspace Facts

- This repo is the canonical home for zsh configuration under `zsh/`; bootstrap links `~/.zshrc` to `zsh/.zshrc.professional` by default, sets `ZSH_CUSTOM` to `~/.config/zsh`, and symlinks `aliases.zsh` into that custom tree so Oh My Zsh loads it.
- Shell config direction: keep one-line shortcuts as aliases; move multi-line or branching logic into named functions or separate sourced files instead of growing `aliases.zsh` only with inline alias functions.
- `scripts/snapshot-zshrc` writes timestamped copies of `~/.zshrc` under `zsh/snapshots/` (ignored by git) and can diff against the canonical file so installer-appended blocks can be merged back deliberately.
- If paths are listed in `.gitignore` but git still reports them as modified, they likely remain in the index and need to be unstaged from tracking (for example `git rm -r --cached <path>`) once—not ignored on disk alone.
- Third-party tools and reference repos are often cloned under `upstream/` using a `repo__owner` directory naming convention aligned with existing git helpers in this dotfiles tree.
- Cursor keybindings live in `cursor/keybindings.json`; observability and conflict-resolution workflows for keybindings are documented in `cursor/docs/keybindings-guide.md`.
- Cursor product learnings (Cloud vs local agents, handoffs, costs) live under `cursor/docs/`; start with `cursor/docs/cursor-cloud-agents-vs-local.md`. Skills authoring/install SoT is `~/projects/agent-skills`, not `cursor/`.
- Origin-first projects (Agents Window **Start from scratch**, or **New** on cursor.com/codebase) live on `origin.cursor.com` with Origin as source of truth. Official **Sync from GitHub** is GitHub→Origin only and would flip SoT. Local clone + private GitHub backup uses named remotes (`origin` + `github`): playbook `cursor/docs/cursor-origin-github-backup.md`, skill `origin-first-gh-mirror`.
- Grok Bot is a standalone SpaceXAI/Cursor agent app (not the IDE model picker); setup notes and first-task prompt live in `cursor/docs/grok-bot-setup.md` with helper `cursor/scripts/grok-bot-setup.sh`.
- Agents Window sidebar clean-slate is manual per-workspace **Archive All** (Automations cannot do it); inventory via `cursor/scripts/cursor-agents-inventory.sh` and notes in `cursor/docs/agents-window-hygiene.md`.
- Cursor 3 has no settings.json default for classic IDE vs Agents Window. This tree wraps `cursor` to inject `--classic` (`cursor/scripts/cursor-classic-wrapper.sh`, `just install-classic-cli`); notes in `cursor/docs/cursor-classic-ide.md`. Escape with `CURSOR_CLASSIC=0` or `--glass`. Do not use `open -a Cursor` for `.code-workspace` files. Do not rewrite Raycast Store extension JS (integrity check → corrupted entry point). Local Raycast fork: `cursor/raycast/cursor-classic-extension/` (`just develop-raycast-classic`); keep the Store Cursor extension disabled. Script-command fallback: `cursor/raycast/script-commands/`.
