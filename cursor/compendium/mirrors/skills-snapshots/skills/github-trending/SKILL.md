---
name: github-trending
description: >-
  Fetch official GitHub Trending (daily/weekly/monthly) via ghtrend or
  gh-trending-page.sh. Use for /github-trending or when the user wants the
  real Trending page — not Search-API topic velocity.
disable-model-invocation: true
---

# Official GitHub Trending

## What this is

**Official** `github.com/trending?since=daily|weekly|monthly` via page scrape (and `ghtrend` alias fallback). Stars are **period gains** from the Trending page.

## How to fetch

Prefer (in order):

1. **Repo justfile** (if in producthunt-quickstart):
   ```bash
   just gh-trending          # daily lines
   just gh-trending weekly
   just gh-trending-json monthly
   ```
2. **Scraper directly:**
   ```bash
   ~/tools/github-gh-cli/scripts/gh-trending-page.sh daily --format lines
   ~/tools/github-gh-cli/scripts/gh-trending-page.sh weekly --format json
   ```
3. **Shell alias** (after sourcing dotfiles): `ghtrend`, `ghtrend weekly`, `ghtrend-clone N weekly`

Setup notes: [`~/dotfiles/GITHUB_TRENDING_SETUP.md`](file:///Users/me/dotfiles/GITHUB_TRENDING_SETUP.md).

Override scraper path with env `GHTREND_PAGE` if needed.

## Not the same as `/gh-trending-ai`

| Signal | Command / tool | Meaning |
|--------|----------------|---------|
| **Official Trending** | `/github-trending`, `ghtrend`, `gh-trending-page.sh` | What GitHub’s Trending page shows |
| **Topic velocity** | `/gh-trending-ai`, `ghta`, `gh-trending-discovery.sh` | Search API by topics/stars/recency |

Do **not** treat Search-API results as “GitHub Trending.” Cross-link the other command when clarifying.

Also distinct: `/gh-clone-trending` (clone flows).

## Known broken (do not rely on)

- `gkze/gh-trending` (`gh trending`) — empty tables / selector drift (2026-07)
- `ghapi.huchen.dev` — DNS dead; aliases may try it then fall back to page scrape

## Related

- PH × GH compare: [`docs/TRENDS_COMPARE.md`](file:///Users/me/tools/producthunt-quickstart/docs/TRENDS_COMPARE.md), `/ph-gh-trends-compare`
- Product Hunt lists: skill `product-hunt-search`
