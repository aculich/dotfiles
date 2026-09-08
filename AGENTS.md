# AGENTS.md

Guidance for AI coding agents working in this bootstrap repo (`me`). Rendered from
[aculich/macos-setup-factory](https://github.com/aculich/macos-setup-factory) at commit `8d723a5`.

## What this repo is

A self-contained recipe for one login: the **common** layer (everything under `home/`, `brew/00-` to `brew/3*`, `script/`, `justfile`) plus this org's **overlay** (`brew/40-*.Brewfile`, `home/dot_zshrc.local`, `script/org-setup`, the org section of README). `script/setup` is the only installer. It runs in waves so the shell works at t=0 and Cursor opens at about minute two.

## Do NOT edit the common tree here

- Do NOT edit files listed in `.factory-manifest`. They are re-rendered by `just reinit-org me` in the factory and your edit will be reverted in the next PR. Change the factory instead.
- Do edit the overlay: `brew/40-*.Brewfile`, `home/dot_zshrc.local`, `script/org-setup`, README org section.

## Placement test (common vs org vs personal)

- Do put a tool in **common** only if every team needs it on day one and its closure is small.
- Do put a tool in the **org overlay** when one team needs it (`brew/40-me.Brewfile`).
- Do put Dock, Finder, window tiling, hot corners, paid casks, and your terminal of choice in the **personal** overlay, never here. iTerm2 is the team terminal; Ghostty is personal.

## Heavy rule

A package is **heavy** when it adds more than 10 new packages to the closure or drags in glib, icu4c, X11, or gnupg. Heavy goes in an opt-in layer named by job (`brew/pdf-ocr.Brewfile`, `brew/media.Brewfile`), never in common. `poppler` is the one exception because `pdftotext` / `pdfinfo` are day-one for every team.

## Shell

- Do keep every line of `home/dot_zshrc` guarded on `$+commands[...]`; the shell must be correct before any bottle lands.
- Do NOT add Oh My Zsh, Prezto, zinit, Sheldon, or Antidote here. Two brew plugins and Starship are the whole prompt story.
- Do NOT write `user.name` / `user.email` into `home/dot_gitconfig`. Identity has one writer per login: `~/.config/git/identity`, written by the org overlay (`script/org-setup`) or the personal overlay.

## Homebrew

- Do NOT install Homebrew from this repo. Adopt `/opt/homebrew`; refuse when it is missing.
- Do NOT `sudo brew`. Delegates run `brew` through the wrapper in `home/dot_zprofile` (`sudo -Hu <owner>`), and scripts through `bootstrap_brew` in `script/lib.sh`, feeding Brewfiles on stdin.
- Do NOT add `~/.Brewfile` or `brew bundle --global`. `script/setup` is the sole installer.
- Do NOT add `--no-upgrade`.
- Do NOT `brew install r`. R is CRAN `.pkg` (rig-compatible). Do NOT ship Anaconda.

## Stale (Do NOT add)

`exa` (use `eza`), `xsv` (use `miller` / `qsv` only for multi-GB), `ag` / `ack` (use `ripgrep`), `htop` beside `btop`, `ncdu` (use `dust` / `duf`), `nvm` / `pyenv` / `rbenv` / `asdf` (use `mise`), `pipx` (use `uv tool`), `mackup`, `tldr`, `youtube-dl` (use `yt-dlp` in a personal overlay), `homebrew/cask-versions` tap, a second `curl` / `zsh` / `git` from brew as the system one, `coreutils` on PATH ahead of BSD tools, `brew python@3.x` as an interpreter (mise pins Python), `cask "gemini"` (MacPaw, not Google).

## Voice

- Do write prohibitions as self-contained **`Do NOT`** lines.
- Do write permissions as **`Do`**.
