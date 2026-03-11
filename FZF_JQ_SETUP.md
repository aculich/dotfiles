# FZF, jq, and friends setup

This document describes the **fzf**, **jq**, and related tools in this dotfiles setup: plugins, keybindings, JSON/YAML/markdown workflows, and upstream clones. Use it to recreate the setup on a new machine.

## What’s in place

- **OH-MY-ZSH plugins:** `jq` (reegnz/jq-zsh-plugin), `zsh-smart-insert` (lgdevlop) – Alt+J for jq query builder; smart path insert with fzf/fd/rg.
- **Fzf keybindings:** From `eval "$(fzf --zsh)"` in `zsh/.zshrc`: Ctrl+T (files), Ctrl+R (history), Alt+C (cd). From `zsh/aliases.zsh`: Esc+z (zz), Esc+p (pz), Esc+d (zd).
- **jq family:** jq, jqless (tap Caps Lock or Esc then `jqless file.json`), `jqrepl` (ajr-style: keys in fzf + live jq preview), jq-zsh-plugin (Alt+J).
- **Pipes / live preview:** `up` (Ultimate Plumber) – pipe any command into it to build pipelines with instant preview; `brew install up`.
- **Structured data:** jq (JSON), yq (YAML/JSON/XML/CSV; mikefarah/yq).
- **Markdown:** `glow` for rendering; `mdr [dir]` to fuzzy-find .md files and open with glow in pager.
- **YouTube:** `yt-x` – browse YouTube (and yt-dlp sites) from the terminal with fzf; script in `~/.local/bin/yt-x`.
- **Upstream clones:** Repos from [LINKS-fzf-jq.md](LINKS-fzf-jq.md) are cloned in `upstream/` with `name__owner` (see [Upstream clones](#upstream-clones)).

## Prerequisites

- **fzf** – `brew install fzf`; then `eval "$(fzf --zsh)"` in zsh (already in `zsh/.zshrc`).
- **fd, ripgrep (rg)** – `brew install fd ripgrep` (for zsh-smart-insert and general use).
- **jq** – `brew install jq`.
- **yq** – `brew install yq` (mikefarah/yq).
- **glow** – `brew install glow` (markdown in terminal).
- **up** – `brew install up` (Ultimate Plumber).
- **gojq** (optional) – for jq-repl from upstream; `brew install gojq`.

## OH-MY-ZSH plugins

- **jq** – Installed at `~/.oh-my-zsh/custom/plugins/jq`. Adds **Alt+J** to open an interactive jq query builder on the current command (uses fzf). Depends: jq, fzf.
- **zsh-smart-insert** – Installed at `~/.oh-my-zsh/custom/plugins/zsh-smart-insert`. Inserts file paths using fzf, fd, rg and custom prefixes. Depends: fzf, fd, rg. Enabled in `plugins=(jq zsh-smart-insert ...)` in `zsh/.zshrc`.

To reinstall zsh-smart-insert:

```bash
git clone https://github.com/lgdevlop/zsh-smart-insert.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-smart-insert
```

## Fzf keybindings

- **From fzf --zsh:** Ctrl+T (paste file path), Ctrl+R (history), Alt+C (cd into directory), Tab (fzf completion with trigger).
- **From aliases.zsh:** Esc+z → `zz` (z + fzf), Esc+p → `pz` (pushd + z + fzf), Esc+d → `zd` (find subdirectory with fzf).

## jq family: when to use which

| Tool | Use case |
|------|----------|
| **jq** | One-off filters: `cat file.json \| jq '.key'`. |
| **jqless** | Interactive “jq + less”: type jq expressions, see result live; Ctrl+X to copy. `brew install jqless` (samsullivan tap). |
| **jqrepl** | Ajr-style: all keys in fzf, type query, see preview. `jqrepl file.json` or `jqrepl -y file.yaml`. Defined in `zsh/aliases.zsh`; needs jq, fzf, yq. |
| **jq-zsh-plugin (Alt+J)** | In the shell: type a command that outputs JSON, press Alt+J, build jq expression, Enter to append. |
| **jq-repl (Rust)** | In `upstream/jq-repl__mklein994`. Build with `cargo build --release` when Rust is new enough; then run from `target/release/jq-repl`. Optional. |

## up (Ultimate Plumber)

Pipe any command into `up` to interactively build a pipeline with live preview. Example:

```bash
lshw |& up
# or
cat file.json | up
```

Then type e.g. `| jq '.key'` and press Enter to see the result. Ctrl+X to save the pipeline to a file and exit. Install: `brew install up`.

## yq (YAML/JSON/XML/CSV)

mikefarah/yq: `brew install yq`. Use for YAML, JSON, XML, CSV (e.g. `yq -o yaml file.json`, `yq '.key' file.yaml`). Documented alongside jq in this setup.

## Markdown: search and render

- **glow** – Render markdown in the terminal; `glow -p file.md` uses the pager.
- **mdr [dir]** – Fuzzy find `.md` files under `dir` (default `.`) with fd+fzf, then open with `glow -p`. Defined in `zsh/aliases.zsh`. Requires: fd, fzf, glow.

Install: `brew install glow`.

## YouTube: yt-x vs youtube-fzf

- **yt-x** (recommended) – Newer, full TUI: feed, trending, search, playlists, watch later, downloads, yt-dlp + fzf. Install:  
  `curl -sL "https://raw.githubusercontent.com/Benexl/yt-x/refs/heads/master/yt-x" -o ~/.local/bin/yt-x && chmod +x ~/.local/bin/yt-x`  
  Dependencies: jq, curl, yt-dlp, fzf, mpv, ffmpeg; optional: gum, chafa. Run: `yt-x`.
- **youtube-fzf** – Older, simpler: browse via subscribed channels database and options (e.g. `--videos`, `--search`). No YouTube Data API. Cloned in `upstream/youtube-fzf__minamotorin` for reference; use yt-x for daily use unless you need the channel-database workflow.

## Upstream clones

Repos from [LINKS-fzf-jq.md](LINKS-fzf-jq.md) are cloned into `upstream/` using the `gcl_` naming: `repo__owner` (e.g. `zsh-smart-insert__lgdevlop`). Alias: `gcl_ <url>` (see `zsh/aliases.zsh`).

Relevant clones for this doc:

- **zsh-smart-insert__lgdevlop** – Source for the OH-MY-ZSH plugin.
- **jq-repl__mklein994** – Rust jq REPL (build from source if desired).
- **ajr__MajorDallas** – Bash-style jqrepl (logic reflected in `jqrepl` in aliases.zsh).
- **up__akavel** – Ultimate Plumber (or use `brew install up`).
- **yt-x__Benexl**, **youtube-fzf__minamotorin** – YouTube CLI tools.
- **gojq__itchyny**, **yq__mikefarah** – gojq and yq upstream.
- **jq-zsh-plugin__reegnz** – jq plugin source (also installed under OH-MY-ZSH custom plugins).

Other clones (Vim, Bitwarden, tmux-1password, BetterCapture, vs-code-recorder, etc.) are in `upstream/` for reference; see [LINKS-fzf-jq.md](LINKS-fzf-jq.md).

## Verify

```bash
# Fzf
fzf --version

# Plugins (after sourcing zshrc)
# Alt+J on a line that would output JSON

# jqrepl
jqrepl --help 2>/dev/null || true
# Usage: jqrepl <file.json> or jqrepl -y <file.yaml>

# up
up -h 2>/dev/null || true

# Markdown
mdr
# (fuzzy find .md, then glow -p)

# yt-x (if ~/.local/bin on PATH)
yt-x --help 2>/dev/null || true
```
