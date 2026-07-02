---
name: bootstrap-new-project
description: Bootstraps a new project root with .gitignore, design/, templates/, data/docs layout, .context/, incoming/, repo-root justfile + docs/AUTOMATION.md (just status pattern), GitHub CLI flow, and nested-git decisions. Existing repos: dry-run plan first; apply only after bootstrap apply / explicit approve or same-message apply. Use when starting a repo, restructuring, or embedding subrepos.
disable-model-invocation: true
---

# Bootstrap New Project Layout

## When to apply

User is creating or normalizing a project root: first commit, monorepo split, adding capture/process pipelines, or clarifying how nested repositories relate to the parent repo.

## 0. Execution contract — dry-run, then apply (existing repos)

**Goal:** Never surprise-mutate a **built-out** repo. **Plan first**, **write second**.

### Classify the target

| Class | Heuristic (agent judgment) |
|-------|------------------------------|
| **Greenfield** | No `.git` yet, **or** `git rev-list --count HEAD` is `0`–`1` with only a handful of tracked files, **or** the user explicitly says **greenfield** / **from scratch** / **empty template**. |
| **Existing** | Otherwise: real history, product/docs trees, `.context/`, `README`, `package.json` / `pyproject.toml`, etc. |

### Pass A — dry-run (required for **Existing**)

On **Existing** repos, the **first** response in a bootstrap session must be **read-only**:

1. Inspect topology (§1), desired layout (§2–5), and git state (`git status -sb`, `git remote -v`, nested `.git` if any).
2. Emit a **Dry-run report** (markdown): every planned **directory create**, **file write**, **`.gitignore` / README / .context` edit**, **`git mv` / subtree / submodule** change, **`gh repo create`**, and **`justfile` + `docs/AUTOMATION.md`** addition. Prefix planned actions with **`[plan]`**.
3. End with a single line: **`NO FILES WRITTEN — DRY RUN ONLY`**.

### Pass B — apply (writes allowed)

Do **not** create, move, or edit tracked files until **one** of:

1. The user’s **next** message explicitly authorizes apply using one of: **`bootstrap apply`**, **`approve bootstrap`**, **`execute the bootstrap plan`**, or **`umbrella bootstrap apply`** (umbrella skill only), **or**
2. The **same** user message already contained both an intent to bootstrap **and** **`apply`** / **`execute`** / **`go ahead`** (e.g. “bootstrap this repo **and apply**”), **or**
3. **Greenfield** (table above) **and** the user confirmed one-shot scaffold in the same message (e.g. “greenfield **apply**”).

If the user replies with questions only, **stay in dry-run** until an **apply** phrase appears.

### `just` + automation docs (new repos)

For **every** repo this skill scaffolds (not only umbrellas), add:

- Repo-root **`justfile`** with **`just`** default = **read-only** `status` (git + inbox snapshot + optional Glow markdown). **Inline a minimal pattern in the bootstrapped repo**—do not require copying from another checkout (e.g. `default: status`, `doctor` listing `git`, `just`, stack CLIs; add `glow` only if the repo uses it). See `docs/AUTOMATION.md` in the new repo.
- **`docs/AUTOMATION.md`** explaining **`just`** vs **Cursor slash skills** vs **`cursor-agent`** / **`claude`** CLI, plus manual **Claude Mac app** flows.

Run **`just doctor`** once after apply to verify `PATH` tools.

## 1. Classify git topology

Answer before laying out directories:

| Situation | Preferred approach |
|-----------|---------------------|
| Single product, one history | One `.git` at root; no nested `.git` inside tracked paths |
| Vendored third-party that must track upstream commits | **Submodule** at fixed path (e.g. `vendor/lib/`) or **subtree** if history should merge into this repo |
| Fork/mirror you edit rarely; clear separation | Dedicated `upstream/` (or `third_party/`) with its **own** `.git`, and **exclude** that tree from the parent via `.gitignore` if it must not be a submodule—document that only one repo “owns” PRs |
| Multiple deployable apps/libs sharing CI | **Monorepo**: root `.git`, packages under `packages/` or `apps/`, no nested `.git` in tracked subtrees |
| Accidental nested `.git` | Remove nested repo from parent index or convert to submodule; never commit sibling `.git` as ordinary files |

**Rule:** At most one “source of truth” git root for any path that the parent repo tracks. If a subdirectory needs independent push/pull, use **submodule** or **subtree**, or keep it **untracked** (gitignored) with documented clone steps—not an unignored nested `.git` unless intentional.

## 2. Recommended top-level layout

Create as needed; skip dirs that do not apply.

```
.
├── .gitignore
├── README.md                    # human-facing overview
├── incoming/                    # unclassified inputs; process then move/delete
├── .context/                    # intent, decisions, prompts, runbooks (see below)
├── design/                      # design substrate (see below)
├── templates/                   # optional: blank forms, boilerplate markdown, copy-per-use scaffolds
├── prompts/                     # optional: copy-paste LLM prompts (or fold into .context/prompts/)
├── docs/                        # published or shareable documentation, examples, reference
├── src/                         # primary application or library code (rename to repo convention)
├── data/
│   ├── raw/                     # immutable or append-only originals
│   ├── interim/                 # reproducible transforms
│   └── processed/               # analysis-ready / exported artifacts
└── (optional per topology)
    packages/                    # monorepo members
    upstream/                    # only if policy = separate clone, gitignored or submodule
```

**`design/` (design substrate):** Put **visual and narrative design artifacts** here so they are not mixed with operational templates or long-form docs. Typical contents: Marp/Deckslide sources (`.marp.md`, `.md` decks), workshop slide masters, storyboards, exported PDFs of decks, design briefs tied to a shipped experience. **Do not** use `design/` as a junk drawer for unrelated files—if something is a blank form, prompt text, or integration code, place it under `templates/`, `prompts/` / `.context/prompts/`, `src/`, or `integrations/` instead.

**Data:** Treat `data/raw` as authoritative originals; never overwrite in place without policy. `interim` and `processed` are reproducible and may be gitignored if large.

**Source:** Prefer one primary tree (`src/`, `apps/`, `packages/<name>/`) consistent with language ecosystem; do not scatter code at repo root unless standard for that stack.

## 3. `.context/` (intent and engineering)

Purpose: durable context for humans and agents—**not** secrets or large binaries.

Suggested files (adjust names to taste):

```
.context/
├── README.md              # what belongs here vs docs/
├── intent.md              # goals, non-goals, success criteria
├── decisions/             # ADR-style notes (001-topic.md)
└── prompts/               # reusable system/user prompt fragments for this repo
```

- Link from root `README.md` to `.context/README.md` in one sentence.
- **Umbrella / long-horizon client repos:** add a **`## Workspace activity`** table to root `README.md` (thresholds + per-area **Last activity** / **Status**) — copy **`context-engineering` / `scaffold/root-readme-workspace-activity.fragment.md`** and wire numbers to **`.context/conventions.md`**; keep it updated whenever **`process-umbrella-incoming`**, **`meeting-sync`**, or **`context-engineering`** touches those areas.
- **Task runner:** add repo-root **`justfile`** + **`docs/AUTOMATION.md`** per **§0** (not optional for scaffolds produced by this skill unless the user explicitly opts out in writing).
- Link from root `README.md` to `design/README.md` when the repo uses a `design/` tree (one sentence: what lives there vs `docs/`).
- Do not store credentials; use env vars and pointer text only.

## 4. `incoming/` workflow

- **Inbox only:** drop `.eml`, exports, screenshots, PDFs, CSV dumps, zip extracts.
- **Processing:** parse, classify, move artifacts to `data/raw`, `docs/`, or `.context/`; delete or archive originals per retention policy.
- **Git:** default **gitignore** `incoming/**` except a `.gitkeep` and `README.md` describing the workflow, **or** ignore only `incoming/*` and track `incoming/README.md`—choose based on whether samples must live in git.
- **Umbrella clients (long horizon):** distinguish **repo-root triage** `incoming/` (unclassified drops + append-only `ROUTING-LOG.md` + `opportunities/`) from **per-engagement** `engagements/<slug>/incoming/` used after a workstream is known. For triage, use **`process-umbrella-incoming`**; for known engagement `.eml`, use **`meeting-sync`** Phase 1b. Full layout: **`bootstrap-umbrella-client-project`**.

## 5. `.gitignore` starter blocks

### Canonical external source

Use **[github/gitignore](https://github.com/github/gitignore)** as the public starting point. It is GitHub’s maintained collection of community-reviewed templates (OS, editors, languages, build tools). When bootstrapping:

1. Start with the **bootstrap base block** below (cross-stack essentials + this skill’s layout rules).
2. **Merge** stack-specific templates from the same repo for every runtime you detect or expect (see table).
3. Prefer **copying upstream patterns** over inventing new ones; link the chosen template paths in `.context/decisions/` when non-obvious.

| Stack / tool | Template in [github/gitignore](https://github.com/github/gitignore) |
|--------------|---------------------------------------------------------------------|
| macOS / Windows / Linux | `Global/macOS.gitignore`, `Global/Windows.gitignore`, `Global/Linux.gitignore` |
| VS Code / JetBrains | `Global/VisualStudioCode.gitignore`, `Global/JetBrains.gitignore` |
| Node / npm / pnpm / yarn / Bun | `Node.gitignore` |
| TypeScript (add to Node) | `+Node.gitignore` patterns: `*.tsbuildinfo`, `.turbo/` |
| Python / uv / poetry / pip | `Python.gitignore` |
| Rust / Cargo | `Rust.gitignore` |
| Go | `Go.gitignore` |
| Java / Gradle / Maven | `Java.gitignore`, `Gradle.gitignore`, `Maven.gitignore` |
| .NET | `Dotnet.gitignore` |
| Docker (local overrides) | `community/Docker/Docker.gitignore` (optional) |

Optional generator (same upstream templates): [gitignore.io](https://www.toptal.com/developers/gitignore) — useful for one-off exports; still treat **github/gitignore** as the source of truth.

**Do not** commit `node_modules/`, `__pycache__/`, `target/` (Rust), `.venv/`, build output (`dist/`, `.next/`, `out/`), or local env files (`.env`).

### Bootstrap base block (polyglot default)

Merge this into every new repo, then add stack rows from the table above. Comments cite upstream files for traceability.

```gitignore
# --- OS (from github/gitignore Global/macOS.gitignore, Global/Windows.gitignore) ---
.DS_Store
.AppleDouble
.LSOverride
._*
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# --- Editors (Global/VisualStudioCode.gitignore, Global/JetBrains.gitignore) ---
*.swp
*.swo
*~
.idea/
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
!.vscode/*.code-snippets
!*.code-workspace

# --- Secrets and local env (Node.gitignore, Python.gitignore) ---
.env
.env.*
!.env.example
.envrc
*.pem
*.key
*.p12
.pypirc

# --- Logs and diagnostics ---
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

# --- JavaScript / TypeScript / Node (Node.gitignore) ---
node_modules/
jspm_packages/
web_modules/
.pnpm-store/
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions
*.tsbuildinfo
.npm
.eslintcache
.stylelintcache
.cache
.parcel-cache
.vite/
.turbo/
.next/
.nuxt/
dist/
out/
.output/
.svelte-kit/
build/Release/
coverage/
*.lcov
.nyc_output/
.serverless/
.dynamodb/
.firebase/

# --- Python (Python.gitignore — essentials) ---
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
.pytest_cache/
.mypy_cache/
.ruff_cache/
.tox/
.nox/
.coverage
.coverage.*
htmlcov/
.hypothesis/
.pytype/
.pyre/
.ipynb_checkpoints/
.venv/
venv/
ENV/
env/
.pdm-python
.pdm-build/
.pixi/*
!.pixi/config.toml
__pypackages__/
.mypy_cache/
dmypy.json
.pybuilder/
/site

# --- Rust (Rust.gitignore) ---
target/
debug/
**/*.rs.bk
*.pdb
**/mutants.out*/
rustc-ice-*.txt

# --- Go (Go.gitignore) ---
*.exe
*.exe~
*.dll
*.dylib
*.test
coverage.*
*.coverprofile
profile.cov
go.work
go.work.sum

# --- Generic build / artifacts ---
*.o
*.a
*.class
*.jar
*.war
*.nar
*.zip
*.tar.gz
*.rar

# --- Data volume (uncomment or tune per repo policy) ---
# data/raw/**
# data/interim/**
# data/processed/**

# --- Incoming inbox (keep README if using ignore-all pattern) ---
incoming/*
!incoming/.gitkeep
!incoming/README.md

# --- Local nested clones not managed as submodules ---
# upstream/
```

### Apply rules

- **Monorepo:** one root `.gitignore`; patterns apply recursively. Add per-package overrides only when a subtree needs exceptions (rare).
- **Detected stack:** if `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` exists, merge the matching **github/gitignore** template in full (not just the base block) and dedupe.
- **Lockfiles:** commit `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lock`, `poetry.lock`, `uv.lock`, `Cargo.lock` unless the project is a published library with explicit policy otherwise — do not blanket-ignore them.
- Tune `incoming/` and `data/` lines to match whether the team commits samples.

## 6. Execution checklist

Copy and track progress:

```
- [ ] §0: Classify Greenfield vs Existing; if Existing, deliver Dry-run report first; wait for bootstrap apply (or equivalent)
- [ ] Confirm monorepo vs single package vs polyrepo with submodules
- [ ] Resolve nested git: submodule, subtree, gitignored clone path, or fold into monorepo
- [ ] Add directory skeleton: incoming/, .context/, design/ (if any decks/specs), templates/ and prompts/ as needed, docs/, src/, data/{raw,interim,processed}
- [ ] Add justfile + docs/AUTOMATION.md (§0); verify `just` and `just doctor`
- [ ] Add .gitignore: bootstrap base block (§5) + merge github/gitignore templates per detected stack
- [ ] Add incoming/README.md and .context/README.md (+ intent stub)
- [ ] Root README: link .context, link design/ when used, describe incoming pipeline, document submodule/upstream policy
- [ ] `git init` + first commit on main (or your default branch)
- [ ] Create **private** GitHub repo with CLI and push (see §8) when the product should live on GitHub
```

## Umbrella / multi-engagement clients

If one **client relationship** drives **multiple dated workstreams** (RFPs, renewals, parallel tracks), prefer **`bootstrap-umbrella-client-project`**: `engagements/` date slugs, `.context/engagements.md`, two-tier `.context/`, and subtree merge for accidental nested repos. Keep this document’s **single-product** layout as the default otherwise.

Also see **`bootstrap-tool-config-repo`** for **tool/editor config mirrors** (Cursor, Claude, Antigravity): sibling **compendium** git repo for `.cursor/`, `.specstory/`, plans backups, and **skills-registry**—not client umbrellas.

## 7. Submodule vs `upstream/` quick reference

- **Submodule:** upstream history visible; `git clone --recurse-submodules` required; good for libraries with their own release cycle.
- **Subtree:** upstream history folded; simpler for consumers; heavier merges.
- **`upstream/` gitignored:** two repos side by side; parent repo never tracks upstream files—document manual sync; avoid duplicate “which repo do I commit in?” confusion in README.

Pick one pattern per dependency and document it in `.context/decisions/` or root README.

## 8. GitHub remote (`gh`) — private repo + push

When the project should exist on GitHub (typical for portable kits and apps), create the remote from the **repo root** after the first meaningful commit:

**Prerequisites:** [GitHub CLI](https://cli.github.com/) installed and authenticated (`gh auth login`).

**Create and push (private, same directory as the git root):**

```bash
cd /path/to/project-root
gh repo create "$(basename "$PWD")" --private --source=. --remote=origin --push
```

- Adjust the repo name if it must differ from the directory name: `gh repo create my-org/peeq-widget --private --source=. --remote=origin --push`.
- If `origin` already exists, use `git remote -v` and either `gh repo create ... --remote=upstream` or skip creation and run `git push -u origin main`.
- If the GitHub repo already exists empty: `git remote add origin git@github.com:USER/REPO.git` then `git push -u origin main`.

**Policy:** Default to **private** unless the user explicitly wants a public open-source repo; confirm visibility before adding `--public`.
