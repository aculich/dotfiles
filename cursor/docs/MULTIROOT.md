# Multi-root workspaces, multirepo, and layout

This page synthesizes **VS Code / Cursor** workspace mechanics, **repository shape** (monorepo vs many repos), **on-disk layout** for code vs design vs data, and **sync** across machines—so you can pick patterns deliberately. It is not a single “right” architecture; products and teams differ.

For **ignore and AI scope** (`.gitignore`, `.cursorignore`, watcher excludes), see [IGNORING.md](IGNORING.md).

## 1. Definitions

- **Multi-root workspace** — A `*.code-workspace` file lists **multiple root folders** in one window. Folders can live **anywhere** on disk (not necessarily one Git repo). [VS Code: Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces)
- **Monorepo** — **One** Git repository containing many packages, apps, or services (often with shared tooling: Nx, Turborepo, Bazel, pnpm workspaces, etc.).
- **Polyrepo / multirepo** — **Many** Git repositories (e.g. one per service or team). You may still open **several** repos in one **multi-root** window for one feature slice.
- **“Virtual monorepo”** — No single giant repo: **many** repos plus **federated** search, CI, or a saved multi-root workspace so day-to-day work *feels* like one surface. Discussed in [Nexumo (2025)](https://medium.com/@Nexumo_/monorepo-vs-polyrepo-code-at-scale-in-2025-9b0743b68b99).

## 2. Cursor-specific notes

- **Agents and multi-root** — Cursor’s changelog describes **multi-root workspaces** in the **Agents** window so a session can target **more than one folder** (e.g. frontend + backend + shared lib) without re-adding folders every turn. [Cursor: Multitask, Worktrees, and Multi-root Workspaces (2024-04-26)](https://cursor.com/changelog/04-24-26)
- **Indexing surface** — Each added root **increases** what the editor can index. Cross-repo and multi-service setups benefit from **aggressive** `.cursorignore` and clear **rules** (e.g. which tree owns which domain). [Developer Toolkit: multi-repo workflows (third-party)](https://developertoolkit.ai/en/cursor-ide/advanced-techniques/multi-repo-workflows/)
- **Reported friction (validate on your build)** — Community threads describe **chat** appearing to use only the **first** opened folder after “Add Folder to Workspace,” and **repeated re-indexing** when adding roots. Treat these as **signals to test**, not stable API guarantees: [forum: multi-root chat context](https://forum.cursor.com/t/how-to-use-cursor-in-multi-root-mode/109645), [forum: indexing loops](https://forum.cursor.com/t/when-i-use-add-folder-to-workspace-codebase-indexing-is-triggered-repeatedly/77053)
- **Cloud / remote agents** — Multi-root helps **one window** see several trees; **Cursor Cloud** and other agent hosts still depend on **what is in the attached workspace, branch, and project rules**. Prefer explicit **docs and rules** for boundaries; see Cursor docs and changelog as the source of truth for current behavior.

## 3. VS Code ergonomics (stable reference)

From [Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces):

- **Workspace file** — `folders[]` with **relative** paths are easier to share than absolute paths.
- **Search** — Scope with `./RootName/**` style includes (see VS Code doc for the exact `files to include` syntax for a single root).
- **Settings** — **Resource** settings (file/folder) can differ per **root**; **workspace**-level settings live in the `.code-workspace` file. **User** settings apply when nothing more specific wins. Editor-wide settings (e.g. zoom) are not set per folder.
- **Tasks and debug** — Configurations from **all** roots appear, often **prefixed** with the folder name; use clear labels (`API: test`, `Web: test`).
- **SCM** — Multiple **Source Control** providers can appear when multiple **Git** repos are open in one window.

**Precedence (common summary):** folder `.vscode/settings.json` overrides workspace `.code-workspace` overrides user settings, for overlapping **resource** keys. [Open Illumi: monorepo / multi-root settings](https://openillumi.com/en/en-vscode-settings-monorepo-multi-root-workspace-fix/) (secondary; VS Code official doc is primary.)

## 4. Monorepo vs polyrepo (decision lens)

Neither shape wins everywhere—you choose **where to pay** complexity: in-repo tooling and discipline **or** in cross-repo coordination. [Unixy: Monorepo vs Polyrepo](https://unixy.io/blog/monorepo-vs-polyrepo/)

**Factors that often favor a monorepo (high level):**

- **Heavy shared code** and **frequent** cross-package changes; willingness to invest in **graph-aware** CI (Nx, Turborepo, Bazel, etc.).
- **One** release or compatibility story; atomic refactors across packages.

**Factors that often favor polyrepo:**

- **Repository-level access control** (compliance, PCI-style boundaries) [Nexumo](https://medium.com/@Nexumo_/monorepo-vs-polyrepo-code-at-scale-in-2025-9b0743b68b99) [Medium decision guide](https://anupamhaldkar.medium.com/monorepo-vs-polyrepo-a-detailed-architecture-decider-guide-e65a0f688c9d)
- **Strong team autonomy** and **independent** release cadences.
- **Polyglot** stacks without appetite for a **multi-language** build (Bazel-class) in one repo. [Medium decision guide](https://anupamhaldkar.medium.com/monorepo-vs-polyrepo-a-detailed-architecture-decider-guide-e65a0f688c9d)

**Hybrids (common in practice):**

- **Domain monorepos** — A few big repos by **business** or **platform**, not one repo for the whole company. [Nexumo](https://medium.com/@Nexumo_/monorepo-vs-polyrepo-code-at-scale-in-2025-9b0743b68b99) [Anupam Haldkar (2026)](https://anupamhaldkar.medium.com/monorepo-vs-polyrepo-a-detailed-architecture-decider-guide-e65a0f688c9d)
- **Platform monorepo + product repos** — Shared SDK / design system **published**; apps consume **versioned** artifacts.
- **Greenfield** — [Unixy](https://unixy.io/blog/monorepo-vs-polyrepo/) and [Nexumo](https://medium.com/@Nexumo_/monorepo-vs-polyrepo-code-at-scale-in-2025-9b0743b68b99) both stress: match **real** dependency and **team** structure; **restructure** later is normal—**drift** without intent hurts more than the initial choice.

**Heuristic (Nexumo-style):** if a large share of work **spans** packages, monorepo “gravity” rises; if almost all work is **local** to one service, polyrepo stays simpler. [Nexumo (2025)](https://medium.com/@Nexumo_/monorepo-vs-polyrepo-code-at-scale-in-2025-9b0743b68b99)

## 5. Greenfield layout patterns (intent-first)

These are **examples**, not requirements.

| Intent | On-disk ideas | Version control & AI notes |
|--------|---------------|----------------------------|
| **Product + shared libraries** | `apps/`, `packages/`, `tooling/`, optional `docs/` | Monorepo fits when you need **atomic** refactors; use **path-based** CODEOWNERS and CI. |
| **API + web + mobile clients** | Separate **deployables** in one repo (monorepo) **or** separate repos with a **shared OpenAPI** / client SDK repo. | In polyrepo, budget **version bumps** and **contract** tests. |
| **Design-heavy (Figma exports, video, large PSD)** | **Not** in Git as binaries by default: object storage, DAM, or design tool links; **short** `design/README.md` in repo with links. | `.cursorignore` on dump folders; **Git LFS** only if your host and team policy support it. |
| **ML / data science** | `data/raw`, `data/processed` (or similar); **DVC** metafiles in Git, blobs in **S3 / GCS / etc.** [DVC: data and model versioning](https://dvc.org/doc/use-cases/data-and-model-files-versioning) | Add `.dvcignore` to keep DVC operations sane [DVC tracking guide](https://mintlify.com/treeverse/dvc/guide/tracking-data) |
| **Intermediate & cache** | `build/`, `dist/`, `.cache/`, experiment `runs/` | In `.gitignore` **and** usually `.cursorignore` / `.cursorindexingignore` so **agents** do not train on throwaway blobs. |

**Design + implementation:** keep **canonical design** in tools teams already use; in Git, track **specs**, **tokens**, and **export contracts** when useful—not every large binary.

## 6. Data outside Git (versioning and backup)

- **Git is for source and small, reviewable text** — Large binaries and **datasets** strain hosts and clones; [DVC](https://dvc.org/doc/understanding-dvc) and similar **pointer + remote** models keep **metadata** in Git and **content** in object storage, with `dvc pull` / `dvc push` after `git checkout`. [DVC use cases](https://dvc.org/doc/use-cases/data-and-model-files-versioning)
- **Larger “lake” scale** — Teams sometimes adopt **lakeFS** or other **data versioning** on object stores; DVC’s docs contrast **file-oriented** vs **lake-scale** options. [DVC: understanding DVC](https://dvc.org/doc/understanding-dvc) (see comparison notes in the doc)
- **Backup** — Remotes (S3, GCS, Azure, SSH) for DVC; **3-2-1** backup thinking still applies: Git host + DVC remote + (optional) org backup policy
- **Secrets** — **Never** store secrets in ignore-only paths; use **1Password / Vault / cloud secret managers** and **short-lived** credentials in agents.

## 7. Multiple laptops and cloud

- **Same repo** — `git pull`; **DVC** (if used) `dvc pull` for the data for your **current commit** [DVC](https://dvc.org/doc/understanding-dvc)
- **Slightly different** trees — `direnv`, documented **env** vars, and committed **`README` / `CONTRIBUTING`** reduce “works on my machine” drift
- **Cloud dev / agents** — Check **which roots** the cloud environment **checks out**, **branch** rules, and **secret** injection; **multi-root** on a laptop may not **map 1:1** to a remote container with one path—**document** the “happy path” for your team
- **Cursor** — Re-read [ignore rules](https://cursor.com/docs/reference/ignore-file) and **indexing** settings when switching machines; global Cursor ignore vs **committed** repo rules affect **teammate parity**

## 8. Sources

Every URL referenced above (for re-checking as tools evolve):

- [Cursor: Ignore file](https://cursor.com/docs/reference/ignore-file)
- [Cursor changelog: Multitask, Worktrees, Multi-root (2024-04-26)](https://cursor.com/changelog/04-24-26)
- [Developer Toolkit: multi-repo workflows](https://developertoolkit.ai/en/cursor-ide/advanced-techniques/multi-repo-workflows/)
- [Cursor forum: How to use multi-root](https://forum.cursor.com/t/how-to-use-cursor-in-multi-root-mode/109645)
- [Cursor forum: Indexing triggered repeatedly when adding folder](https://forum.cursor.com/t/when-i-use-add-folder-to-workspace-codebase-indexing-is-triggered-repeatedly/77053)
- [VS Code: Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces)
- [Open Illumi: VS Code monorepo / multi-root settings](https://openillumi.com/en/en-vscode-settings-monorepo-multi-root-workspace-fix/)
- [Unixy: Monorepo vs polyrepo (decision framework)](https://unixy.io/blog/monorepo-vs-polyrepo/)
- [Medium / Anupam Haldkar: Monorepo vs polyrepo (2026)](https://anupamhaldkar.medium.com/monorepo-vs-polyrepo-a-detailed-architecture-decider-guide-e65a0f688c9d)
- [Medium / Nexumo: Monorepo vs polyrepo (2025)](https://medium.com/@Nexumo_/monorepo-vs-polyrepo-code-at-scale-in-2025-9b0743b68b99)
- [DVC: Data and model file versioning](https://dvc.org/doc/use-cases/data-and-model-files-versioning)
- [DVC: Understanding DVC](https://dvc.org/doc/understanding-dvc)
- [DVC tracking guide (Mintlify)](https://mintlify.com/treeverse/dvc/guide/tracking-data)

**Related in this repo:** [IGNORING.md](IGNORING.md) · [MULTIROOT-cursor-lifecycle.md](MULTIROOT-cursor-lifecycle.md) (Cursor chat history, renames, plans, archival tools) · [PROSE-VCS.md](PROSE-VCS.md) (markdown/plans in git vs prose-aware review) · [worktree-vcs-landscape.md](worktree-vcs-landscape.md) · [COMPENDIUM.md](COMPENDIUM.md) (private sibling backup repo) · [CURRENT_STATE.md](../CURRENT_STATE.md)
