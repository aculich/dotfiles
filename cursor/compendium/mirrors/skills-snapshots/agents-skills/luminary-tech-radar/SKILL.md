---
name: luminary-tech-radar
description: Mirrors a public GitHub user plus gists, tier-searches related repos, samples fork traction, runs two parallel-cli web searches to JSON, and writes RADAR + LANDSCAPE markdown reports. Use for “tech radar”, “mirror all repos”, “track luminary”, “gist mirror”, “fork analysis”, or repeating the Karpathy-style workflow for another GitHub handle.
metadata:
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
---

# Luminary Tech Radar

## When to use

- You want a **reproducible snapshot**: upstream repos + gists + bounded related repos + fork metrics + two web-search JSON corpora + two markdown reports.
- You are following a **public AI / OSS luminary** and care about **ecosystem forks** and **third-party commentary**, not only their own posts.

## Prereqs

- `gh` authenticated, `git`, `jq`, `parallel-cli` on PATH.
- A writable repo path such as `radar/<handle>/` with `mirrors/` gitignored.

## Command — parallel web search (copy verbatim)

Pick a short filename stem (lowercase, hyphens). Objective first; add `-q` refiners; **always** `-o` JSON.

```bash
parallel-cli search "$OBJECTIVE" \
  -q "keyword-one" -q "keyword-two" \
  --json --max-results 12 --excerpt-max-chars-total 27000 \
  -o "$FILENAME.json"
```

When summarizing, cite **only** URLs present in that JSON (plus label any curator-provided seeds separately).

## Execution checklist

**1. Layout**

- [ ] `radar/<handle>/` tree: `manifests/`, `mirrors/{repos,gists,related}/`, `search/`, `reports/`, `prompts/`, `scripts/`
- [ ] `.gitignore` includes `radar/<handle>/mirrors/` (track manifests, search JSON, reports, scripts)

**2. Upstream mirror** (`sync-upstream.sh` pattern)

- [ ] `gh repo list <handle> --limit 200 --json name,isFork,updatedAt,stargazerCount,url,pushedAt` → `manifests/<handle>-repos.json`
- [ ] Shallow clone each repo to `mirrors/repos/<name>/` (skip if exists)
- [ ] `gh api --paginate /users/<handle>/gists | jq -s add` → `manifests/<handle>-gists.json`
- [ ] Shallow clone each gist to `mirrors/gists/<id>/`

**3. Tiered related discovery** (`discover-related.sh` pattern)

- [ ] Multiple `gh search repos "<query>"` (gist URL, `github.com/<handle>`, flagship repo names…)
- [ ] `jq -s 'add | unique_by(.fullName)'` → `related-repos-raw.json`
- [ ] Filter out `<handle>/*`, apply recency/stars floor, sort by stars, cap `RELATED_MAX_CLONE` → `related-repos.json`
- [ ] Clone winners to `mirrors/related/<owner>__<repo>/`

**4. Fork sampling** (`collect-forks.sh` pattern)

- [ ] For parents with `stargazerCount ≥ PARENT_MIN_STARS`, `gh api repos/<handle>/{repo}/forks?per_page=…&sort=stargazers`
- [ ] Merge rows → `fork-activity.json` (stars + `pushed_at`; optional `ahead_by` only if budgeted)

**5. Web search JSON**

- [ ] Pass A — writing + appearances (blogs, arXiv author hub, interviews, courses)
- [ ] Pass B — third-party commentary referencing GitHub + gists
- [ ] Save under `search/`; note `search_id` in reports

**6. Reports**

- [ ] `<HANDLE>_RADAR.md` — inventory + thresholds + **Sources** (from JSON)
- [ ] `<HANDLE>_LANDSCAPE.md` — themes + limitations + **Sources** (same JSON URLs only for web claims)

**7. Meta**

- [ ] Parameterized `prompts/MASTER_LUMINARY_RADAR_PROMPT.md`
- [ ] Optional HeyPresto MCP (`user-heypresto`, tool `expand_prompt`) → `prompts/*.expanded.md`; see `HEYPRESTO_STATUS.md` if MCP is offline

## Tunables (document in `config.yaml` or env)

| Variable | Typical default |
|----------|-----------------|
| `RELATED_MAX_CLONE` | 100 |
| `RELATED_MAX_AGE_MONTHS` | 24 |
| `PARENT_MIN_STARS` | 500 |
| `MAX_FORKS_PER_PARENT` | 100 |
| `CLONE_DEPTH` | 1 |

## Reference implementation

See the Karpathy run under your checkout’s `radar/karpathy/` directory — copy `scripts/*.sh`, `config.yaml`, and adapt handle plus search queries.
