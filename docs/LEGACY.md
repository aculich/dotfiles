# What was in dotfiles-pre20260906

Scanned 2026-09-07 from [aculich/dotfiles-pre20260906](https://github.com/aculich/dotfiles-pre20260906) (~4281 blobs). We are **not** importing that tree. Zsh starts over.

## How we treat each bucket

| Path / cluster | What it was | New setup |
|----------------|-------------|-----------|
| `zsh/` (~23 files: `.zshrc.professional`, OMZ/Zim snapshots, site-specific UUID rc, profiling) | Hand-maintained + symlink install | **Replace.** Chezmoi `dot_zshrc` + Starship + Sheldon (scenario A). Do not copy `.zshrc.professional`. |
| `zsh/site-specific/` | Per-machine rc keyed by Hardware UUID | `~/.zshrc.local` untracked, or chezmoi `hostname` templates later |
| `bash/` | `.bashrc` / `.bash_profile` | Skip unless a tool still needs bash |
| `cursor/` (~4130 files) | Cursor workspace dumps | **Leave.** Not dotfiles; bloated the old repo |
| `.cursor/`, `.specstory/`, SpecStory.md | Editor/chat exhaust | Leave (or tiny snippets later under `home/dot_cursor/` if we declare them) |
| `karabiner/` | Caps Lock JSON fragments | [macos-reinstall `apps/karabiner`](https://github.com/aculich/macos-reinstall) already owns Karabiner. Essentials still does Caps Lock via `defaults`. |
| `package.list` | Mixed brew/cask URLs (AeroSpace, FlashSpace, yabai, …) | **Brewfile / PACKAGES.md**, not this repo |
| `bootstrap.sh`, `setup.sh` | `ln -sf` into `$HOME` | **chezmoi apply** via `script/setup` |
| `config/api-credentials/`, `scripts/migrate-secrets-to-1password*.sh`, `.env.1password` | 1Password + direnv wiring | Keep the **idea** (secrets in `op`, never git). Rewrite against chezmoi templates + `1password@beta` / CLI beta. Do not copy scripts or `.env*` |
| `envrc/` | direnv templates | Re-add later as `home/dot_config/direnv/` if we want direnv |
| `config/cursor-hooks/` | Cursor hooks + 1Password validate | Re-derive a small declared hook set when we need it |
| `scripts/` (MCP, Chrome form recovery, profiling, worklogbranch) | One-off tools | Cherry-pick into a `bin/` **after** we miss them; not day one |
| Root markdown (`SETUP_GUIDE`, `MIGRATION_*`, `FZF_JQ_SETUP`, `DATABASE_CLI`, …) | Docs for the old shell | Leave; fzf/jq are brew (PACKAGES want), not zsh copies |
| `1pass-docs/`, `1PASSWORD_*.md` | Vault how-tos | Optional read; secrets stay in 1Password |
| `history.list` | Shell history | **Never** track |
| `*.mp3` | Podcast dump | Leave |
| `vs-code-recorder/` | VS Code | Cursor is primary |
| `omz.lightning` | OMZ experiment | Scenario A uses OMZ as plugin catalog only |
| `archive/` | Old copies | Leave |

## Re-derive vs restore

- **Re-derive:** look at an old file (or a Mackup copy), write a *small* chezmoi source that we understand, `chezmoi apply`.
- **Restore:** drop a blob back on disk (Mackup link, `cp` a plist). Fine as a one-time rescue, not the catalog.

Mackup lives in macos-reinstall (copy mode). Use it to **see** iTerm/Raycast/GUI prefs, then promote keepers into git-reviewable text here or into `apps/*/CUSTOM.md` over there.
