---
name: research-clone-bootstrap
description: >-
  Bootstraps a dual Cursor workspace lab for OSS landscape research and product
  development from a seed URL (product site or GitHub). Creates product/ + peers/
  trees, dual-engine search (Parallel CLI + Exa), naming/namespace exploration,
  alternatives matrix, package PRDs, SUPER_PRD, and separate workspaces so peer
  clones never pollute product indexing. Use when the user runs
  /research-clone-bootstrap or asks to scaffold a research+product lab from a
  competitor URL (Raycast-like, Amethyst-like, Rectangle-like, etc.).
license: MIT
compatibility: >-
  Cursor Agent (slash command + skills). Requires bash/zsh, git, gh (optional),
  network. Dual search expects parallel-cli and/or Exa MCP.
metadata:
  version: "1.0.0"
  author: aculich
  author_url: https://github.com/aculich
  homepage: https://github.com/aculich/research-clone-bootstrap
  canonical: https://github.com/aculich/research-clone-bootstrap
  monorepo: https://github.com/aculich/agent-skills
  category: research-ops
  tags: macos,oss,landscape,prd,naming,exa,parallel
disable-model-invocation: true
---

# Research-clone bootstrap

Repeatable pattern distilled from Jumpkey: **catalog everything** (including proprietary), **clone GitHub peers outside the product workspace**, **brainstorm product names**, write **package PRDs → SUPER_PRD**, then implement only what you choose.

## Invocation

```
/research-clone-bootstrap https://www.raycast.com/
/research-clone-bootstrap https://github.com/ianyh/amethyst
/research-clone-bootstrap https://www.raycast.com/ --slug raycast
```

Optional: `--slug raycast` `--root ~/tools/macosx-tools/labs`

Companion slash command: [`assets/cursor-command.md`](assets/cursor-command.md) (install to `~/.cursor/commands/research-clone-bootstrap.md`).

### Slug vs product name

| Term | Meaning |
|------|---------|
| **`--slug`** | Lab directory + workspace id only (filesystem). Usually derived from the **seed** hostname or GitHub repo name (`raycast`, `amethyst`). **Not** the final OSS product name. |
| **Product name** | What you ship (`Jumpkey`, `Keyloom`, …). Always explored in `research/NAMING.md`, even when the user already has a favorite. |

Never assume `labs/<slug>/` implies the product will be called `<slug>`. Using the seed trademark as a product name is usually a bad idea (Raycast®, etc.).

## Layout created

```
labs/<slug>/
  README.md
  product/                         # YOUR future OSS product (git)
    justfile, .gitignore, README
    <slug>.code-workspace          # PRODUCT only — open for implementation
    research/
      SEED.md, SEARCH_TERMS.md, SEARCH_COMPARE.md, NAMING.md
      alternatives-matrix.md
      packages/_TEMPLATE.md (+ one PRD per peer)
      SUPER_PRD.md, SPEC.md, GITHUB.md
      docs/, binaries/MANIFEST.json, search-archives/
  peers/                           # study clones — NOT in product workspace
    repos.txt, sync.sh, .gitignore
    <slug>-research.code-workspace # RESEARCH only
    clones/owner__repo/            # shallow clones (gitignored)
```

**Hard rule:** never add `peers/clones` as a folder root in the product `.code-workspace`.

## Agent checklist

```markdown
Research-clone bootstrap:
- [ ] 1. Run scripts/bootstrap.sh <url> [--slug] [--root]
- [ ] 2. Fetch seed (web_fetch / gh) → fill research/SEED.md classification
- [ ] 3. Decompose capabilities → SEARCH_TERMS.md clusters + queries
- [ ] 4. Dual landscape search (Parallel CLI + Exa) on the same core queries
      → archive JSON under research/search-archives/
      → fill SEARCH_COMPARE.md (union peers; note engine-only hits)
- [ ] 5. NAMING.md — brainstorm 8–15 candidates; check GitHub name hits + DNS
      for .com/.app (and note trademarks). Always run even if user named a product.
- [ ] 6. alternatives-matrix.md from **union** of both engines (+ proprietary rows)
- [ ] 7. Append GitHub owner/repos to peers/repos.txt; just research-clone-all
- [ ] 8. For each notable peer: research/packages/<name>.md from _TEMPLATE.md
- [ ] 9. Proprietary peers: docs + binaries/MANIFEST.json (no illegal redistribution)
- [ ] 10. Synthesize SUPER_PRD.md (clusters, non-goals, milestones, naming shortlist)
- [ ] 11. Offer: open product vs research workspace; private gh repo create
- [ ] 12. Stop — no large implementation until user picks scope + preferred name
```

## Search tooling (Parallel + Exa)

**Default: run both** on the same 2–4 core queries from `SEARCH_TERMS.md`.

| Engine | How | Strengths |
|--------|-----|-----------|
| **Parallel CLI** | `parallel-cli search "<objective>" -q "…" --json -o search-archives/parallel-….json` | Community threads, product sites, AlternativeTo-style aggregators; durable JSON archives |
| **Exa MCP** | `web_search_exa` / `web_fetch_exa` | Dense GitHub README hits; good for discovering concrete `owner/repo` peers |

If `parallel-cli` is missing: tell user to run `/parallel-setup`, continue with Exa, and note the gap in `SEARCH_COMPARE.md`.

Do **not** treat either engine as sole source of truth — merge into the matrix.

## Naming phase

Write `research/NAMING.md`:

1. Brainstorm candidates (evocative, spellable, not the seed trademark).
2. For each shortlist: `gh api "search/repositories?q=<name>+in:name&per_page=1"` total_count; `dig`/DNS for `<name>.com` and `<name>.app`.
3. Note collisions (existing launchers, trademarks) — overlapping names may still be chosen, but document risk.
4. SUPER_PRD links to a **shortlist of 3**; user picks later.

Optional future flag: `--product-name Foo` seeds the shortlist but does **not** skip brainstorming.

## Phase details

### 1. Scaffold

Resolve the skill root (this directory), then:

```bash
<path-to-skill>/scripts/bootstrap.sh 'https://www.raycast.com/' --slug raycast
```

Default root: `~/tools/macosx-tools/labs/<slug>/`.

See [references/gotchas.md](references/gotchas.md) for monorepo clone size and path pitfalls.

### 2–3. Seed + search terms

- Product site → proprietary / hybrid; GitHub → note license, stars, language.
- Clusters = user-facing jobs (launcher, clipboard, window mgmt, AI chat, extensions…).
- Each cluster gets 3–8 search strings for GitHub + web.

### 4–7. Dual search → matrix + clones

- **Always** row proprietary peers even with no clone.
- Clone only public GitHub; shallow; `owner__repo` dirs.
- Skip pathological monorepos (e.g. `raycast/extensions`) — note in matrix, browse on GitHub.

### 8–10. Package PRDs → SUPER_PRD

One file per peer worth learning from. Mark: fork base / pattern only / coexistence / skip.

Templates live under [`templates/`](templates/).

### 11. Workspaces

```bash
cursor labs/<slug>/product/<slug>.code-workspace
cursor labs/<slug>/peers/<slug>-research.code-workspace
```

## Related skills

- `parallel-web-search` — Parallel CLI search skill
- Exa MCP (`web_search_exa`) — complementary discovery

## Clean-room

Study peers for patterns. Do not paste proprietary or incompatible-license source into the product tree without an explicit license decision in SUPER_PRD / GITHUB.md.
