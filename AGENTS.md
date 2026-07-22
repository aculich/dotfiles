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
