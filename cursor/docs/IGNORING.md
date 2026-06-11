# Ignoring: git, Cursor, and the editor

Large monorepos drown **git**, **file watchers**, **search**, and **@codebase / AI indexing** in the same low-value paths: virtualenvs, `__pycache__`, `node_modules`, build output, and vendored clones. **First**, know how **Git** combines ignore rules (section 0). **Then** use **three policy layers** for the repo: **1** version control, **2** Cursor AI, **3** editor UI—they do not replace each other.

## 0. Git ignore sources (precedence)

Git merges several sources of ignore patterns. Order and “last match wins” behavior are defined in the [gitignore documentation](https://git-scm.com/docs/gitignore.html).

| Source | Typical location | Use for |
|--------|------------------|---------|
| **Committed `.gitignore`** | Repo root and subdirectories | Rules **every** clone should share: build outputs, dependency dirs, env filename patterns, language-specific cache dirs. |
| **`.git/info/exclude`** | Local to one clone | Paths you refuse to add to team policy—personal or machine-only quirks, not worth a commit. |
| **Global excludes** | `core.excludesfile` — often `~/.gitignore_global` or [`$XDG_CONFIG_HOME/git/ignore`](https://git-scm.com/docs/gitignore.html) (see Git docs) | **Machine-wide** noise: `.DS_Store`, temp editor files, tools only you use—avoids churn and opinion wars in the repo’s `.gitignore`. |

A useful mental split (see also [gitignore vs exclude](https://yytuda.com/gitignore-vs-exclude/)): shared project rules in **tracked** `.gitignore`; personal or OS-level noise in **global** excludes or `.git/info/exclude`.

**Debug a path:** `git check-ignore -v <path>` prints which pattern ignored it.

**Minimal global Git config (optional, alongside dotfiles):**

- `git config --global core.excludesfile ~/.config/git/ignore` — or another path; wire it to your global ignore file.
- `git config --global init.defaultBranch main` — if you want the same default branch for every new `git init` (orthogonal to ignores but often set in the same pass).

**Secrets:** ignoring `*.env` does not protect keys already committed. Use secret managers, secret scanning, and committed `.env.example` files—treat ignore rules as preventing *accidental* `git add`, not as security control.

## 1. Version control: `.gitignore` (in the tree)

- **Purpose:** what must not be committed for this repository.
- **Scope:** Git only. It does *not* by itself stop the editor from watching or indexing (unless another tool reuses the same rules).

Keep environment file **patterns**, generated artifacts, and dependencies out of version control. In polyglot repos, a **root** `.gitignore` plus **nested** `.gitignore` files (per app or per language) is normal. **Section 0** covers how that interacts with global and `exclude` rules.

## 2. Cursor AI and indexing: `.cursorignore` and `.cursorindexingignore`

The [Cursor ignore-file reference](https://cursor.com/docs/reference/ignore-file) is authoritative; behavior can change between versions.

- **`.cursorignore`** — Best-effort **exclusion** from **semantic search**, **Tab / Agent / Inline** context, and **@**-driven context for many flows. Treat as a **practical** barrier, not a security guarantee: **use secret managers and real access control for credentials**, not ignore files alone.
- **`.cursorindexingignore`** — Excludes paths from **codebase indexing** (search / @ retrieval style behavior). Content may still be openable or attachable in some flows where the product allows **manual** inclusion; prefer this for *large but occasionally needed* trees (e.g. legacy dirs) so you can narrow automatic noise without a full block.
- **Defaults:** Cursor also applies built-in and `.gitignore`-aware defaults for many binary and lockfile patterns; see the same doc for the current list.

**Hierarchical Cursor Ignore** (Settings → Features → Editor): when enabled, Cursor can search **parent** directories for `.cursorignore` files, which helps in **monorepos** with nested package roots. See [MULTIROOT.md](MULTIROOT.md) for multi-root and folder-scoped layout.

**User-level global ignore patterns** in Cursor settings: optional way to add patterns for **all** projects on a machine. Prefer **committed** `.cursorignore` / `.cursorindexingignore` when a team should share the same AI scope.

**Important caveat ([docs](https://cursor.com/docs/reference/ignore-file)):** **Terminal** and **MCP** tooling used by the Agent are **not** governed by `.cursorignore` the same way as chat context. Do not assume ignored paths are invisible to every agent capability.

**Negation:** `!` patterns follow gitignore-style rules; excluded **directories** may not be traversed, so re-including deep files can fail if a parent is excluded with `*`. See Git’s gitignore notes and Cursor’s doc for limitations.

**Verify:** after edits, check **Codebase Indexing** (indexed file count) and spot-check `@codebase` / search behavior.

Keep high-churn dirs **aligned** between `.gitignore` and Cursor ignores so @codebase does not pull in tens of thousands of `.pyc` or `node_modules` files. You can still **@ mention** a specific file where the product allows. Some teams document SpecStory (or similar) with a narrow exception in the indexing file.

**Note:** Cursor’s exact behavior can evolve; treat the pair of files as “minimize noise for AI” plus “minimize index size,” and re-read release notes after upgrades.

## 3. VS Code / Cursor UI: `files.watcherExclude`, `search.exclude`, optional `files.exclude`

In **`.vscode/settings.json`** (workspace, folder, or user):

| Setting | What it affects |
|--------|------------------|
| `files.watcherExclude` | File system watchers (e.g. `fileWatcher` in `cursor -s`). Reduces CPU churn on huge trees. |
| `search.exclude` | Quick search and similar; often mirror watcher excludes for artifacts. |
| `files.exclude` | **Explorer / file tree** only. Hides matching paths in the sidebar. Use only if you are fine not seeing those files without toggling. |

**Multi-root workspaces** (`.code-workspace` with several folders): each root can have its own **`.vscode/settings.json`**; resource settings apply per folder, while shared cross-cutting options often live in the **workspace file**. See [Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces) and [MULTIROOT.md](MULTIROOT.md) for search scoping, tasks, and SCM with multiple roots.

Use the same **path families** in watcher and search for venvs, caches, `node_modules`, `dist/`, `build/`, and large reference clones.

**Extensions and MCPs** are not configured in these three keys. Heavy language servers, spell checkers, and MCP servers (each may spawn **separate Node processes**) add to Activity Monitor. Prefer **per-workspace** disable for extensions and only enable MCPs you need for the current project.

## Why duplicate rules in a monorepo root and a subfolder (e.g. an engine package)

If you only open a **subfolder** as the workspace, **only that folder’s** `.cursorignore`, `.cursorindexingignore`, and `.vscode/settings.json` apply. Root-level patterns that start with `pkg/foo/` are wrong when the workspace root *is* `pkg/`. Mirror the **same intent** with **paths relative to each workspace root**.

## Patterns that almost always belong in “ignore for tools” (not only git)

- **Python:** `.venv/`, `.venv-*/`, `__pycache__/`, `*.pyc`, `.mypy_cache/`, `.pytest_cache/`, `.ruff_cache/`, `.tox/`, `.nox/`
- **Node:** `node_modules/`, `dist/`, `build/` (when generated)
- **Vendored research / clones:** e.g. `upstream/`, or a package-specific `upstream/` under a service
- **Generated output:** e.g. `output/`, `papers/` if they are build artifacts, not hand-edited source
- **Session / editor noise:** e.g. `.specstory/**` if you use that workflow

## Worked example: `storytelling-capsules`

The `storytelling-capsules` monorepo (path on disk: e.g. `~/projects/storytelling-capsules`) uses:

- Root: `.cursorignore`, `.cursorindexingignore`, `.vscode/settings.json` for the full tree (engine, examples, `incoming/`, etc.).
- `storyvale-engine/` as a subfolder: its own `.cursorignore`, `.cursorindexingignore`, and `.vscode/settings.json` for when that folder is opened alone.

Repository-specific notes and greenfield advice: `REFACTOR.md` in that repo. This dotfiles doc stays **project-agnostic**.

## Checklist for a new repo

- [ ] **Global** Git excludes file configured (`core.excludesfile`) with OS / personal noise
- [ ] Root **`.gitignore`** (and nested where needed) for secrets, generated files, and stack outputs
- [ ] **`.cursorignore` + `.cursorindexingignore`** for AI and index scope; re-check **Codebase Indexing** file count after changes
- [ ] **`.vscode/settings.json`** with `files.watcherExclude` and `search.exclude` for artifacts and large reference dirs
- [ ] If you use a subpackage as a standalone workspace, duplicate the **same policy** with paths relative to that root
- [ ] Use `git check-ignore -v` when a path is unexpectedly ignored or not ignored
- [ ] Revisit after `cursor -s` or Activity Monitor if watcher or extension count is still high

**See also**

- [MULTIROOT.md](MULTIROOT.md) — multi-root workspaces, monorepo vs polyrepo, data layout, multi-machine
- [CURRENT_STATE.md](../CURRENT_STATE.md) — what this `cursor` dotfiles tree contains and how it is organized
