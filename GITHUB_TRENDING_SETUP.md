# GitHub Trending Setup

This document describes how to get **GitHub trending repos** working in this dotfiles setup: the `ghtrend` / `ghtrend-clone` aliases and the `gh trending` extension. Use it to recreate the setup on a new machine.

## What’s in place

- **`ghtrend`** (in `zsh/aliases.zsh`) – Lists trending repos. Tries the public API (ghapi.huchen.dev) first; if that fails, falls back to `gh trending` when the extension is installed.
- **`ghtrend-clone N`** – Clones the first N trending repos (same API; no extension fallback for clone).
- **`gh trending`** – Provided by the **gh-trending** extension. Shows trending repos in a table (or JSON), with optional language filter and `--web` to open in the browser.

## Prerequisites

- **GitHub CLI (`gh`)**  
  Install if needed:
  ```bash
  brew install gh
  ```
- **Authenticated `gh`** (for any `gh`-based features):
  ```bash
  gh auth login
  ```
- **jq** (used by `ghtrend` when the API works):
  ```bash
  brew install jq
  ```
- **curl** – Usually present on macOS.

## Install the gh-trending extension

One-time install:

```bash
gh extension install gkze/gh-trending
```

- Extension is installed under: **`~/.local/share/gh/extensions/gh-trending`**
- To see it:
  ```bash
  gh extension list
  ```
- To upgrade later:
  ```bash
  gh extension upgrade gh-trending
  ```

## Verify

```bash
# Extension (table output; may log some scrape warnings to stderr)
gh trending

# With options
gh trending --help
gh trending python
gh trending --web
gh trending -o json

# Dotfiles alias (uses API first; if API is down, runs gh trending when extension is installed)
ghtrend
ghtrend weekly
ghtrend daily python
```

## Recreating on another machine

1. Install prerequisites: `gh`, `jq` (and `curl` if missing).
2. Log in: `gh auth login`.
3. Install the extension: `gh extension install gkze/gh-trending`.
4. Ensure this repo’s zsh config is active (e.g. `~/.zshrc` sources `dotfiles/zsh/aliases.zsh` or you use the professional zsh setup).
5. Reload the shell or run `source ~/dotfiles/zsh/aliases.zsh` (adjust path if your dotfiles live elsewhere).
6. Run `ghtrend` or `gh trending` to confirm.

## Behavior summary

| Command           | Source              | Notes |
|-------------------|---------------------|--------|
| `ghtrend [since] [lang]` | ghapi.huchen.dev → else `gh trending` | API can be down; then extension is used automatically. |
| `ghtrend-clone N [...]`  | ghapi.huchen.dev only   | No extension fallback; requires API. |
| `gh trending [lang]`     | Extension (scrapes GitHub) | Can log “Did not find href” to stderr; table/JSON still printed. |

## If the public API is down

- **`ghtrend`** will print a short message and, if the extension is installed, run **`gh trending`** for you.
- You can always run **`gh trending`** directly, or open **https://github.com/trending** in the browser.

## References

- Extension repo: [gkze/gh-trending](https://github.com/gkze/gh-trending)
- Public API (used by `ghtrend` when available): [huchenme/github-trending-api](https://github.com/huchenme/github-trending-api) (live at ghapi.huchen.dev)
- Aliases: `zsh/aliases.zsh` (search for `ghtrend` or `gh trending`)
