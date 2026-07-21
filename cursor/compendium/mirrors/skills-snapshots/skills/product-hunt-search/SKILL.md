---
name: product-hunt-search
description: >-
  Query Product Hunt via Cursor MCP (user-product-hunt) or repo GraphQL
  fallback. Use when the user asks for PH posts, ranking, votes, topics,
  slugs, /product-hunt-search, or /product-hunt-ranking.
disable-model-invocation: true
---

# Product Hunt search

## Prefer MCP

Use Cursor MCP server **`user-product-hunt`** (jaipandya `product-hunt-mcp`):

| Tool | When |
|------|------|
| `get_posts` | Lists with filters / sort |
| `get_post_details` | Known `id` or `slug` |
| `get_post_comments` | Comments on a post |
| `search_topics` / `get_topic` | Topic discovery |
| `get_user` / `get_viewer` | Maker / viewer |
| `check_server_status` | Auth / readiness |

Discover schemas with `GetMcpTools` before calling tools.

## Critical caveat: no post keyword search

The Product Hunt GraphQL API and this MCP **do not** support free-text search over post names/taglines.

**Do instead:**

- Known product → `get_post_details(slug=…)` (or `url` if exposed)
- Category → `search_topics` then `get_posts(topic=…)`
- “What’s hot now” → `get_posts(order=RANKING, …)`
- “Sticky / can’t-live-without” → `get_posts(order=VOTES, …)`
- Time windows → `posted_after` / featured filters when available

If the user asks to “search for X”, say you cannot keyword-search posts; try slug, topic, or RANKING/VOTES lists.

## Fallback (no MCP)

From [`~/tools/producthunt-quickstart`](file:///Users/me/tools/producthunt-quickstart) with `.env` `PRODUCT_HUNT_TOKEN`:

```bash
cd ~/tools/producthunt-quickstart
just ph-ranking 10
just ph-votes 10
just ph-query '{"query":"{ viewer { user { username } } }"}'
python3 scripts/ph_query.py --file docs/examples/query-viewer.json
```

Credentials: [`docs/CREDENTIALS.md`](file:///Users/me/tools/producthunt-quickstart/docs/CREDENTIALS.md).  
MCP smoke history: [`MCPTEST.md`](file:///Users/me/tools/producthunt-quickstart/MCPTEST.md).

## Related

- PH × GitHub compare methodology: [`docs/TRENDS_COMPARE.md`](file:///Users/me/tools/producthunt-quickstart/docs/TRENDS_COMPARE.md) and `/ph-gh-trends-compare`
- Official GitHub Trending (different surface): skill `github-trending` / `/github-trending`
