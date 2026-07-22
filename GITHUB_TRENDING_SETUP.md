# GitHub Trending Setup

How to get **official GitHub Trending** (`daily` / `weekly` / `monthly`) working in this dotfiles setup.

## What’s in place (2026-07 refresh)

| Command | Source | Notes |
|---------|--------|-------|
| **`ghtrend [since] [lang]`** | `ghapi.huchen.dev` → else **page scrape** | Primary CLI. Since: `daily` (default), `weekly`, `monthly`. |
| **`ghtrend-clone N [...]`** | Same as `ghtrend` | Clones first N repos from that list. |
| **`gh-trending-page.sh`** | [`~/tools/github-gh-cli/scripts/`](file:///Users/me/tools/github-gh-cli/scripts/gh-trending-page.sh) | Stdlib Python scrape of `github.com/trending?since=…`. Prefer `--format json` for agents/MCP. |
| **`gh trending`** (gkze extension) | Installed under `~/.local/share/gh/extensions/gh-trending` | **Broken as of 2026-07** (empty table; HTML selector drift). Keep installed but do not rely on it. |
| **`ghta` / `gh-trending-discovery.sh`** | `~/tools/github-gh-cli` | **Different signal:** GitHub Search API by topic/stars/recency — label as “topic velocity,” not official Trending. |

Aliases live in [`zsh/aliases.zsh`](zsh/aliases.zsh) (`ghtrend`, `ghtrend-clone`, `_ghtrend_json`).

## Prerequisites

```bash
brew install gh jq
# python3 is required for the page scraper (stdlib only; no pip packages)
gh auth login   # optional for scrape; required for gh-trending-discovery / ghta
```

## Verify

```bash
source ~/dotfiles/zsh/aliases.zsh   # or open a new shell

ghtrend
ghtrend weekly
ghtrend monthly
ghtrend daily python

# Raw JSON (best for scripts / future MCP)
~/tools/github-gh-cli/scripts/gh-trending-page.sh weekly --format json | jq '.[0]'

# Clone top 3 this week
# ghtrend-clone 3 weekly
```

## Recreating on another machine

1. Install `gh`, `jq`, and ensure `python3` exists.
2. Clone/sync this dotfiles repo and `~/tools/github-gh-cli` (or set `_GHTREND_PAGE` to the scraper path).
3. Source `zsh/aliases.zsh`.
4. Run `ghtrend weekly` — should list repos even when `ghapi.huchen.dev` is down.
5. Optional: `gh extension install gkze/gh-trending` (nice-to-have; currently broken).

## Known failures (do not use as primary)

- **`ghapi.huchen.dev`** — DNS dead (Jul 2026); aliases still try it first, then fall back.
- **`gkze/gh-trending`** — scrape selectors outdated; emits `Did not find href attr` and empty tables.
- **Apify / paid trending actors** — not recommended for day-to-day.

## Future Cursor MCP (thin wrapper)

Do **not** invent a separate stack. When you want agent-global access, mirror Product Hunt:

```json
{
  "mcpServers": {
    "github-trending": {
      "command": "/Users/me/tools/github-gh-cli/scripts/gh-trending-page.sh",
      "args": ["daily", "--format", "json"]
    }
  }
}
```

Better: a tiny wrapper that accepts `since` as an MCP tool argument and shells out to `gh-trending-page.py --since … --format json`. Same pattern as `producthunt-quickstart/scripts/run-product-hunt-mcp.sh`.

## References

- Page scraper: `~/tools/github-gh-cli/scripts/gh-trending-page.py`
- Topic velocity (complement): `~/tools/github-gh-cli/scripts/gh-trending-discovery.sh`
- PH × GH compare (example consumer): `~/tools/producthunt-quickstart/docs/TRENDS_COMPARE.md`
- Extension (legacy): [gkze/gh-trending](https://github.com/gkze/gh-trending)
- Dead public API: [huchenme/github-trending-api](https://github.com/huchenme/github-trending-api)
