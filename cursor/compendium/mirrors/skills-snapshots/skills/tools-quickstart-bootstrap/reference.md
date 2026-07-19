# Tools Quickstart Bootstrap Reference

This reference expands the workflow in `SKILL.md`.

## Directory layout template

### New quickstart repo

```text
~/tools/<tool>-quickstart/
├── upstream/
│   └── <org>__<repo>/
├── background/
│   ├── TECHSTACK.md
│   ├── ARCHITECTURE.md
│   ├── RESEARCH_KEYWORDS.md
│   ├── LANDSCAPE.md
│   ├── USECASES.md
│   ├── UPSTREAM_PIN.txt
│   ├── project-scan-full.json
│   └── parallel-cache/
├── EXECSUMMARY.md
├── PRAXIS.md
├── TOOLBOX.md
├── justfile
├── META.md
└── .gitignore
```

**Legacy layout (pre-2026-07):** `docs/` + `design/` — migrate to `background/` when editing an older quickstart.

### In-place bootstrap (existing `~/tools/<name>/`)

Same files at the **existing repo root**. May also have:

```text
~/tools/chrome-extensions/          # example
├── .agents/skills/                 # project-local skills (npx skills add, no -g)
├── skills-lock.json
├── AgentBoard/                     # subprojects (no single upstream/)
├── tabwrangler/
└── …
```

Do not require `upstream/<org>__<repo>/` at the root unless the repo is single-tool focused; subfolders may already vendor upstream (e.g. `copyallurls-clone/upstream/`).

## Suggested authoring order

1. `.gitignore` and repo hygiene.
2. **`justfile`** from template below (customize variables; merge if one exists).
3. Install + smoke tests (`--help`, `version`) — or inventory existing subprojects + manifests.
4. Write `background/UPSTREAM_PIN.txt` (commit, version, date) — or `just pin`.
4. `EXECSUMMARY.md` (purpose, audience, where it fits/does not fit).
5. `PRAXIS.md` (daily workflow and commands).
6. `background/TECHSTACK.md` and `background/ARCHITECTURE.md`.
7. Keyword matrix and landscape searches.
8. **`npx skills find`** (find-skills): cache JSON → `TOOLBOX.md` (install user-selected skills project-local).
9. `background/LANDSCAPE.md` and `background/USECASES.md` (include agent-skills landscape + pointer to `TOOLBOX.md`).
10. **Canonical upstream verification** on all cited repos (see SKILL.md).
11. `META.md`.
12. Commit.
13. Offer tiered follow-up bootstraps for landscape alternatives.

### UPSTREAM_PIN.txt template

```text
repo: <org>/<repo>
url: https://github.com/<org>/<repo>
commit: <full-sha>
version: <from pyproject/package.json if present>
pinned: YYYY-MM-DD
clone_path: upstream/<org>__<repo>
```

### TOOLBOX.md template (sections)

1. How skills are installed in this repo (`.agents/skills/`, `skills-lock.json`, no `-g` by default)
2. **Installed (project-local)** — table: skill, source, installs, role, re-install command
3. **Explicitly not installed** — with reason
4. **Recommended (not installed)** — when to add
5. **Relevant skills elsewhere** — `~/.cursor/skills/`, `~/.agents/skills/`, MCP plugins
6. **Non-skill tooling** — CLIs, browser steps
7. **Maintenance** — `npx skills check` / `update`; `just update` for full refresh loop

## Justfile template

Customize variables at the top per quickstart. **In-place bootstrap:** merge new recipes into an existing justfile; never clobber `default` or domain-specific recipes (e.g. karakeep `run`/`docker`).

Conventions (match awesome-awesome + agent-skills):

- Doc comment (`# ...`) above every recipe so `just --list` self-documents.
- `default: @just --list --unsorted`
- **`help: default`** — `just help` must list recipes (bare `just` alone is not enough; people type `help`).
- `update` as DWIM batch recipe.
- awesome-awesome paths guarded with `[ -d "$aa" ]`.
- **Runtime stack visibility (required when `ps` / compose / daemon recipes exist):**
  - `just status` ends with `just ps` (or equivalent) after git/pin/docs.
  - `just start` and `just stop` (and peers) print `just ps` **before and after** the lifecycle action.
  - **Never `cd` before a nested `just` call** — just resolves the justfile from cwd. Run compose/`cd` in a **subshell** `( cd … && … )`, or pass `--justfile` / `--working-directory` to the repo root.
- **Terminal color (prefer built-ins, no custom ANSI helpers):**
  - Section banners: just constants `{{BOLD}}` `{{CYAN}}` `{{NORMAL}}` and `{{style("warning")}}` / `style("error")` / `style("command")` (just ≥1.x with `style()`).
  - Markdown dumps (e.g. ROTATION-PLAN): prefer `glow` if on PATH (`brew install glow`), else plain `head`.
  - Optional preference: `export JUST_COMMAND_COLOR=blue` (colors echoed recipe lines; CLI/env only — not a justfile `set`).

```just
# <tool>-quickstart maintenance
# Run bare `just` to list recipes.

tool := "<tool-slug>"
tool_label := "<Human Tool Name>"
upstream_dir := "upstream/<org>__<repo>"
upstream_repo := "<org>/<repo>"
upstream_url := "https://github.com/<org>/<repo>"
search_terms := "<primary-term> <secondary-term>"
integration_phrase := ""  # optional multi-word gh query, e.g. "iris Hermes" for hermes-agent
skills_queries := "<query-one> <query-two>"
smoke_cmd := ".venv/bin/<cli> --help"
cache_dir := "background/parallel-cache"
pin_file := "background/UPSTREAM_PIN.txt"
landscape_file := "background/LANDSCAPE.md"
awesome_awesome := "/Users/me/tools/awesome-awesome"
date := `date +%F`

default:
    @just --list --unsorted

# Recipe menu (same as bare `just`)
help: default

# Git + upstream pin + doc freshness (+ runtime ps when stack exists)
status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== {{tool_label}} quickstart status ==="
    git status -sb 2>/dev/null || echo "(not a git repo)"
    if [[ -d "{{upstream_dir}}/.git" ]]; then
      echo "Upstream local: $(git -C {{upstream_dir}} rev-parse --short HEAD 2>/dev/null || echo missing)"
      echo "Upstream remote: $(git -C {{upstream_dir}} ls-remote origin HEAD 2>/dev/null | cut -f1 | head -c 12 || echo unavailable)"
    else
      echo "Upstream: {{upstream_dir}} not cloned"
    fi
    [[ -f {{pin_file}} ]] && echo "Pin file:" && cat {{pin_file}} || echo "Pin file: missing (run: just pin)"
    for f in EXECSUMMARY.md PRAXIS.md {{landscape_file}} TOOLBOX.md; do
      if [[ -f "$f" ]]; then
        echo "Doc $f: $(stat -f '%Sm' -t '%Y-%m-%d' "$f" 2>/dev/null || stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)"
      fi
    done
    # When this quickstart has a runtime stack, always end status with process visibility:
    # just ps
    # (omit the call only if there is no ps/compose/daemon recipe)

# Write background/UPSTREAM_PIN.txt from current upstream HEAD
pin:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p background
    commit="$(git -C {{upstream_dir}} rev-parse HEAD)"
    ver=""
    [[ -f {{upstream_dir}}/pyproject.toml ]] && ver="$(grep -E '^version\s*=' {{upstream_dir}}/pyproject.toml | head -1 | sed 's/.*"\(.*\)".*/\1/' || true)"
    [[ -z "$ver" && -f {{upstream_dir}}/package.json ]] && ver="$(node -p "require('./{{upstream_dir}}/package.json').version" 2>/dev/null || true)"
    ver="${ver:-unknown}"
    printf '%s\n' \
      "repo: {{upstream_repo}}" \
      "url: {{upstream_url}}" \
      "commit: $commit" \
      "version: $ver" \
      "pinned: {{date}}" \
      "clone_path: {{upstream_dir}}" \
      > {{pin_file}}
    cat {{pin_file}}

# Batch maintenance (does not auto-synthesize docs)
update: update-upstream update-landscape update-skills update-integrations update-security
    @echo "Batch update complete. Run printed agent prompts to refresh LANDSCAPE / TOOLBOX."

# Pull vendored upstream and re-pin
update-upstream:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ ! -d "{{upstream_dir}}/.git" ]]; then echo "Missing {{upstream_dir}}"; exit 1; fi
    old="$(git -C {{upstream_dir}} rev-parse HEAD)"
    git -C {{upstream_dir}} pull --ff-only || git -C {{upstream_dir}} fetch origin
    new="$(git -C {{upstream_dir}} rev-parse HEAD)"
    just pin
    echo "--- diffstat since previous pin ---"
    git -C {{upstream_dir}} diff --stat "$old".."$new" | tail -20 || true
    mkdir -p {{cache_dir}}
    git -C {{upstream_dir}} log --oneline "$old".."$new" > {{cache_dir}}/upstream-changelog-{{date}}.txt 2>/dev/null || true

# Re-verify LANDSCAPE sources; print synthesis prompt
update-landscape:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{cache_dir}}
    out="{{cache_dir}}/source-verify-{{date}}.json"
    echo "[" > "$out"
    first=1
    while IFS= read -r url; do
      [[ "$url" =~ github.com/([^/]+)/([^/]+) ]] || continue
      owner="${BASH_REMATCH[1]}"; repo="${BASH_REMATCH[2]%.git}"
      if command -v gh >/dev/null; then
        line="$(gh api "repos/$owner/$repo" --jq "{full_name, fork, parent: .parent.full_name, stars: .stargazers_count, pushed_at}" 2>/dev/null || echo "{\"full_name\":\"$owner/$repo\",\"error\":true}")"
        [[ $first -eq 1 ]] && first=0 || echo "," >> "$out"
        echo "$line" >> "$out"
      fi
    done < <(grep -oE 'https://github.com/[^ )>]+' {{landscape_file}} 2>/dev/null | sort -u)
    echo "]" >> "$out"
    echo "Cached: $out"
    echo ""
    echo "=== AGENT PROMPT (paste into Cursor) ==="
    echo "Refresh background/LANDSCAPE.md for {{tool_label}} using {{cache_dir}}/source-verify-{{date}}.json."
    echo "Verify canonical upstream URLs; add Integrations section if update-integrations cache exists."

# Re-run skills find; print TOOLBOX prompt
update-skills:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{cache_dir}}
    for q in {{skills_queries}}; do
      slug="$(echo "$q" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
      npx skills find "$q" 2>&1 | tee {{cache_dir}}/skills-find-${slug}-{{date}}.txt || true
    done
    echo ""
    echo "=== AGENT PROMPT ==="
    echo "Update TOOLBOX.md from {{cache_dir}}/skills-find-*-{{date}}.txt for {{tool_label}}."

# Tiered integration discovery
update-integrations:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{cache_dir}}
    out="{{cache_dir}}/integrations-{{date}}.txt"
    aa="{{awesome_awesome}}"
    catalog="$aa/data/processed/awesome-catalog.full.jsonl"
    {
      echo "# Integrations discovery {{tool_label}} {{date}}"
      echo "## Tier 0 catalog"
      if [[ -f "$catalog" ]]; then
        echo "Catalog mtime: $(stat -f '%Sm' -t '%Y-%m-%d' "$catalog" 2>/dev/null || stat -c '%y' "$catalog" | cut -d' ' -f1)"
        for term in {{search_terms}}; do
          echo "--- grep: $term ---"
          rg -i "$term" "$catalog" | head -15 || true
        done
      else
        echo "Catalog missing at $catalog"
      fi
      echo "## Tier 1 local awesome clones"
      if [[ -d "$aa/upstream" ]]; then
        for term in {{search_terms}}; do
          rg -il "$term" "$aa/upstream/" 2>/dev/null | head -10 || true
        done
      fi
      echo "## Tier 2 gh search (updated + description)"
      if command -v gh >/dev/null; then
        for q in {{search_terms}}; do
          echo "--- gh search updated: $q ---"
          gh search repos "$q" --sort updated --limit 10 --json fullName,description,stargazersCount 2>/dev/null \
            | jq -r '.[] | "\(.fullName) (\(.stargazersCount)★) — \(.description // "" | .[0:100])"' 2>/dev/null || true
          echo "--- gh search in:description: $q ---"
          gh search repos "$q in:description" --sort stars --limit 10 --json fullName,description,stargazersCount 2>/dev/null \
            | jq -r '.[] | "\(.fullName) (\(.stargazersCount)★) — \(.description // "" | .[0:100])"' 2>/dev/null || true
        done
        for phrase in "{{tool_label}}" "{{upstream_repo}}"; do
          echo "--- gh search phrase: $phrase ---"
          gh search repos "$phrase" --sort updated --limit 10 --json fullName,description,stargazersCount 2>/dev/null \
            | jq -r '.[] | "\(.fullName) (\(.stargazersCount)★) — \(.description // "" | .[0:100])"' 2>/dev/null || true
        done
        if [[ -n "{{integration_phrase}}" ]]; then
          echo "--- gh search integration phrase: {{integration_phrase}} ---"
          gh search repos "{{integration_phrase}} in:description" --sort stars --limit 10 --json fullName,description,stargazersCount 2>/dev/null \
            | jq -r '.[] | "\(.fullName) (\(.stargazersCount)★) — \(.description // "" | .[0:100])"' 2>/dev/null || true
        fi
      fi
      echo "## Ongoing digest grep"
      latest="$(ls -t "$aa/docs/reports/awesome-trends-"*.md 2>/dev/null | grep -E 'awesome-trends-[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' | head -1 || true)"
      if [[ -n "$latest" ]]; then
        echo "Digest: $latest"
        for term in {{search_terms}}; do
          rg -i "$term" "$latest" | head -10 || true
        done
      fi
    } | tee "$out"
    echo ""
    echo "=== AGENT PROMPT ==="
    echo "Add Integrations section to background/LANDSCAPE.md from $out. Verify canonical upstream for each repo."

# Security advisories + awesome-awesome security lens
update-security:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{cache_dir}}
    out="{{cache_dir}}/security-{{date}}.txt"
    {
      echo "# Security watch {{tool_label}} {{date}}"
      if command -v gh >/dev/null; then
        echo "## GitHub advisories {{upstream_repo}}"
        gh api "/repos/{{upstream_repo}}/dependabot/alerts" --jq '.[] | {severity, summary: .security_advisory.summary}' 2>/dev/null | head -20 || echo "(no token or no alerts API)"
      fi
    } | tee "$out"
    aa="{{awesome_awesome}}"
    if [[ -f "$aa/justfile" ]]; then
      just -d "$aa" --justfile "$aa/justfile" lens security date={{date}} || true
    fi
    echo ""
    echo "=== AGENT PROMPT ==="
    echo "Review $out and awesome-awesome security lens report; note CVEs in META or LANDSCAPE if material."

# Canonical upstream check for all LANDSCAPE github URLs
verify-sources:
    @just update-landscape

# Smoke test from PRAXIS
smoke:
    #!/usr/bin/env bash
    set -euo pipefail
    {{smoke_cmd}}

# Show rotation gate status (ROTATION-PLAN.md if present)
rotate-status:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -f ROTATION-PLAN.md ]]; then
      echo "=== ROTATION-PLAN.md (head) ==="
      head -30 ROTATION-PLAN.md
      if rg -q 'Election:.*unset|Status: pending' ROTATION-PLAN.md 2>/dev/null; then
        echo ""
        echo "WARN: rotation election still pending — prefer rotate-before-doit, or set Election to skip-legacy-smoke-only"
      fi
    else
      echo "no ROTATION-PLAN.md (ok if no livewires hits)"
    fi

# End-to-end: deps → start → open UI when ready (after rotation election)
# Customize ensure-deps / start / open per tool. Refuse if rotation pending unless elected skip.
doit: rotate-status ensure-deps start open
    @echo "doit complete — see PRAXIS.md for smoke checks"

# Tool-specific stubs — override in each quickstart justfile
ensure-deps:
    @echo "TODO: ensure-deps for {{tool_label}}"

# When a runtime stack exists, bookend with `just ps` before/after.
# Critical: do NOT `cd` into docker/ before nested `just` — use a subshell for compose.
# start: ensure-deps
#     #!/usr/bin/env bash
#     set -euo pipefail
#     echo "=== ps (before start) ==="
#     just ps || true
#     ( cd {{docker_dir}} && {{compose}} up -d )
#     echo "=== ps (after start) ==="
#     just ps
#
# stop:
#     #!/usr/bin/env bash
#     set -euo pipefail
#     echo "=== ps (before stop) ==="
#     just ps || true
#     ( cd {{docker_dir}} && {{compose}} stop )
#     echo "=== ps (after stop) ==="
#     just ps

start:
    @echo "TODO: start for {{tool_label}}"

stop:
    @echo "TODO: stop for {{tool_label}}"

ps:
    @echo "TODO: ps for {{tool_label}} (compose ps / process list)"

open:
    @echo "TODO: open UI for {{tool_label}}"
```

**Per-tool variable examples:**

| Quickstart | `tool_label` | `upstream_repo` | `search_terms` | `smoke_cmd` |
| --- | --- | --- | --- | --- |
| hermes-agent | Hermes Agent | NousResearch/hermes-agent | hermes-agent hermes agent | `.venv/bin/hermes --help` |
| metasphere-agents | Metasphere Agents | julianfleck/metasphere-agents | metasphere claude code harness | `.venv/bin/metasphere --help` |
| codeburn | Codeburn | getagentseal/codeburn | codeburn claude token usage | `npx codeburn --help` or built CLI path |

## Canonical upstream verification (detail)

Run for every GitHub URL in `background/LANDSCAPE.md` Sources and compatibility matrix.

```bash
gh api repos/<owner>/<repo> --jq '{fork, parent: .parent.full_name, stars: .stargazers_count, pushed_at, archived}'
```

| Signal | Action |
| --- | --- |
| `fork: true` | Switch citation to `parent.full_name` unless fork is intentionally ahead |
| Same repo name, different owner, 10x+ star gap | Prefer higher-star canonical org |
| `archived: true` on upstream | Note in LANDSCAPE; may cite active fork with justification |
| 0 stars, unknown owner | Do not cite without verification |

Record verification in META or a brief note in LANDSCAPE Sources when a non-obvious choice was made.

## Post-bootstrap alternatives follow-up (detail)

Extract peer tools from `background/LANDSCAPE.md` compatibility matrix and narrative research. Present tiers via structured question:

- **Tier 1:** direct competitors or “likely better” by activity/fit — default recommendation to bootstrap
- **Tier 2:** complements (orchestrator pairs, adjacent stack layers)
- **Tier 3:** long tail from search — optional batch

If user selects items, re-invoke this skill with `/tools-quickstart-bootstrap <url>` for each.

## Dual-tool orchestrator pattern

When two tools are meant to work together:

1. Create `~/tools/<tool-a>-quickstart/`
2. Create `~/tools/<tool-b>-quickstart/`
3. Create `~/tools/<shared-stack-repo>/` for integration contracts
4. Keep deep tool docs in each quickstart
5. Keep cross-tool contracts and deployment decisions in shared repo

Recommended shared repo layout:

```text
~/tools/<shared-stack-repo>/
├── background/
│   ├── INTEGRATION_ARCHITECTURE.md
│   ├── SELF_HOSTING_PLAYBOOK.md
│   └── INTEROP_MATRIX.md
├── scripts/
│   ├── make_contract.sh
│   ├── check_contract.sh
│   └── check_output.sh
├── META.md
└── README.md
```

Dual-tool checkpoints:

- Validate each tool independently before linking.
- Define input/output boundaries before writing orchestration scripts.
- Track licensing/deployment posture per tool and for the combined stack.
- Verify canonical upstream for both tools and cited integration peers.
- Commit each repo independently in logical batches.

## Canonical section checklist

### EXECSUMMARY

- Purpose
- Objective
- Use cases
- Audience
- Expected outcomes
- No-brainer fit
- Not-yet fit
- Bottom line

### PRAXIS

- Install
- Configure
- Core commands
- Workflow loops
- Deployment stance
- Verification notes

### TECHSTACK (background/)

- Runtime and package manager
- Dependency graph
- Provider surface
- Practical implications

### ARCHITECTURE (background/)

- Mermaid system diagram
- Layer responsibilities
- Data/control flow
- Why this architecture works

### LANDSCAPE (background/)

- Concept lens
- Component lens
- Narrative post angles
- Builder post angles
- Sources (canonical upstream URLs only, unless fork justified)
- Raw cache pointers

### USECASES (background/)

- Upstream-stated use cases
- Local-context use cases
- Pantheon contribution model
- Reusable template for future case capture

### META

- Narrative of what was done
- Replicable numbered workflow
- Recursive improvement loop
- Anti-patterns to avoid

## Quality bar

- Keep claims factual and cited where external.
- Cite canonical upstream repos; never mirror/fork URLs without justification.
- Keep docs concise and navigable.
- Separate observed facts from interpretation.
- Prefer reproducible commands over prose-only guidance.
