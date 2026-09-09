# aculich/dotfiles

The **common layer**, rendered for my own login. Same tree every team repo carries (`home/`, wave Brewfiles, `script/setup`, `justfile`), no org overlay. My personal overlay is a second chezmoi source in [aculich/dotfiles-private](https://github.com/aculich/dotfiles-private); this repo has no name, no email, no licenses. Team-minimal Dock and an empty login allowlist live here (`dock/`, `login/`); the rich `me` lists are private.

Rendered from [aculich/macos-setup-factory](https://github.com/aculich/macos-setup-factory) at `6a18fd1` on 2026-09-08. Edit common things there, then `just reinit-org me`. Files in `.factory-manifest` are re-rendered; `docs/` is mine.

## New Mac (machine + person)

Strap first: FileVault, Homebrew, CLT, software update. It clones `aculich/dotfiles` and runs `script/setup`, then `script/strap-after-setup` blocks until the wave chain finishes.

```bash
git clone https://github.com/MikeMcQuaid/strap ~/src/strap
STRAP_GITHUB_USER=aculich bash ~/src/strap/bin/strap.sh
```

Then, as me, the personal overlay:

```bash
gh repo clone aculich/dotfiles-private ~/src/dotfiles-private
cd ~/src/dotfiles && just apply-private
```

## Existing Mac

```bash
gh repo clone aculich/dotfiles ~/src/dotfiles
~/src/dotfiles/script/setup       # shell now, Cursor at ~2 min, rest in background
just status wait
```

## What is here

| Path | Job |
|------|-----|
| `home/` | chezmoi source: `dot_zprofile` (brew shellenv + delegate `brew()` wrapper), `dot_zshrc` (guarded; Scenario A), `dot_gitconfig` (identity via include), Starship, mise, global gitignore |
| `home/.chezmoiscripts/` | `00-brew-bundle` (re-run wave 0 on change), `10-macos-defaults` (common login defaults + will-cite), `30-uv-tools`, `40-dock-login` |
| `brew/00-shell` `10-common` `20-data-common` | waves 0-2 |
| `brew/30-llm-vendor` `31-local-dev` `32-drift` | wave 4 |
| `brew/pdf-ocr` `brew/media` | opt-in by job: `just bundle pdf-ocr` / `media` / `data-heavy` |
| `script/setup` | the installer (waves) |
| `script/preflight` | machine-layer check for a hire's Mac |
| `script/strap-after-setup` | `just status wait` |
| `justfile` | status, bundle, apply, apply-private, dock, login-keep, doctor, bench, drift |
| `dock/` `login/` | team-minimal Dock + empty login allowlist (`just dock`, `just login-keep`) |
| `docs/` | LEGACY (what the pre-2026-09-06 tree had), SHARING (public safeguards) |

Wave 5 for me is `just apply-private` when `~/src/dotfiles-private` exists.

## Public later

Private today. Flip to public only after `gitleaks detect --source . --log-opts=--all` is clean and a template audit finds no literal email, name, hostname or `op://` path with personal metadata. Nothing on any team depends on this repo being public: org repos carry their own rendered common tree.

See `AGENTS.md` for the placement test, the heavy rule, and the Stale list.
