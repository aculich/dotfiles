# Ignoring: git, Cursor, and the editor

Large monorepos drown **git**, **file watchers**, **search**, and **@codebase / AI indexing** in the same low-value paths: virtualenvs, `__pycache__`, `node_modules`, build output, and vendored clones. Use **three layers**; they do not replace each other.

## 1. Version control: `.gitignore`

- **Purpose:** what must never be committed.
- **Scope:** Git only. It does *not* stop the editor from watching or searching (unless the tool respects gitignore by default, which varies).

Keep environment files, secrets, and generated artifacts out of the tree. In polyglot repos, a **root** `.gitignore` plus **package** `.gitignore` files (e.g. per app or per language) is normal.

## 2. Cursor AI and indexing: `.cursorignore` and `.cursorindexingignore`

- **`.cursorignore`** — paths excluded from **Cursor AI context** (what the model “sees” for many operations).
- **`.cursorindexingignore`** — paths excluded from **codebase indexing** used for @ references and retrieval-style features.

Keep these **aligned** for high-churn dirs so @codebase does not pull in tens of thousands of `.pyc` or `node_modules` files. You can still **@ mention** a specific file if your workflow allows explicit inclusion; some teams also document SpecStory or similar tools with a narrow exception in the indexing file.

**Note:** Cursor’s exact behavior can evolve; treat the pair of files as “minimize noise for AI” plus “minimize index size.”

## 3. VS Code / Cursor UI: `files.watcherExclude`, `search.exclude`, optional `files.exclude`

In **`.vscode/settings.json`** (workspace or user):

| Setting | What it affects |
|--------|------------------|
| `files.watcherExclude` | File system watchers (`fileWatcher` in `cursor -s`). Reduces CPU churn on huge trees. |
| `search.exclude` | Quick search and similar; often mirror watcher excludes for artifacts. |
| `files.exclude` | **Explorer / file tree** only. Hides matching paths in the sidebar. Stricter: use only if you are fine not seeing those files without toggling. |

Use the same **path families** in watcher and search for venvs, caches, `node_modules`, `dist/`, `build/`, and large reference clones.

**Extensions and MCPs** are not configured here. Heavy language servers, spell checkers, and MCP servers (each may spawn **separate Node processes**) add to Activity Monitor. Prefer **per-workspace** disable for extensions and only enable MCPs you need for the current project.

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

- [ ] Root `.gitignore` (and nested where needed) for secrets and generated files
- [ ] `.cursorignore` + `.cursorindexingignore` for AI and index scope
- [ ] `.vscode/settings.json` with `files.watcherExclude` and `search.exclude` for artifacts and large reference dirs
- [ ] If you use a subpackage as a standalone workspace, duplicate the **same policy** with paths relative to that root
- [ ] Revisit after `cursor -s` or Activity Monitor if watcher or extension count is still high

See also: [LAYOUT.md](LAYOUT.md) for how to place product code vs pipeline vs artifacts vs vendored trees.
