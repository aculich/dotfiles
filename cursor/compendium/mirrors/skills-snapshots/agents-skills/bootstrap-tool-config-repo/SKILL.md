---
name: bootstrap-tool-config-repo
description: Normalizes dotfiles tool-config repos (Cursor, Claude, Antigravity) with dry-run then apply, attic/ for non-destructive moves, and a sibling private compendium git repo for mirrored project .cursor/, .specstory/, global and per-project plans, plus skills-registry (vendor vs authored vs project). Documents autocommit presets (default daily on compendium only). Use when reorganizing cursor/ config tracking, setting up cross-project backups, or cloning the pattern for another IDE home.
disable-model-invocation: true
---

# Bootstrap tool-config repo and compendium

## When to use

- Normalizing **`dotfiles/cursor/`** (or similar) without treating it as a product monorepo or **client umbrella** (`bootstrap-umbrella-client-project` is wrong for this).
- Defining how a **sibling private git compendium** mirrors `~/.cursor/plans`, per-project `.cursor/plans`, project `.cursor/` and optional `.specstory/`, and tracks **skills provenance** (vendor vs self-authored vs project skills).
- Copying the pattern for **Claude Code**, **Antigravity**, etc. (sibling skill: same structure, different paths).

**Not for:** application `src/` trees, `engagements/`, or umbrella `incoming/ROUTING-LOG`.

## 0. Execution contract — dry-run, then apply

Same gate as [bootstrap-new-project §0](file:///Users/me/.cursor/skills/bootstrap-new-project/SKILL.md):

| Class | Heuristic |
| --- | --- |
| **Greenfield** | New compendium dir with no `.git` yet, or user says greenfield scaffold. |
| **Existing** | Real history in `dotfiles/cursor/` or compendium—**dry-run first**. |

### Pass A — dry-run (required for **Existing**)

1. Inspect git topology, `docs/`, `snapshots/`, proposed `attic/`, and **`CURSOR_COMPENDIUM_ROOT`** (or planned sibling path).
2. Emit a **Dry-run report**: every `[plan]` mkdir, `git mv`, symlink, compendium script change, `.gitignore` edit, registry YAML change.
3. End with **`NO FILES WRITTEN — DRY RUN ONLY`**.

### Pass B — apply

Writes only after **`bootstrap apply`**, **`approve bootstrap`**, **`execute the bootstrap plan`**, **`tool-config bootstrap apply`**, or same-message **`apply`** / **`go ahead`**.

## 1. Compendium contract

- **Purpose:** Backup + cross-project index—not always the live edit surface for product code.
- **Location:** Sibling private repo (e.g. `~/src/dotfiles-cursor-compendium`). Set **`CURSOR_COMPENDIUM_ROOT`** to that clone root.
- **Tracked scaffold in dotfiles:** Reference layout and scripts live under [`dotfiles/cursor/compendium/`](/Users/me/dotfiles/cursor/compendium) in this tree; **copy** that directory to the sibling, `git init`, create private `origin`, then run snapshots into the clone (or maintain the scaffold via submodule—pick one ADR). **Live instance:** see `dotfiles/cursor/docs/COMPENDIUM.md` after bootstrap (path, remote URL, env, launchd).
- **Secrets:** Never mirror `mcp.json`, raw `.env`, keys, or tokens. Scripts use **`--exclude`** / deny globs; extend denylist in `scripts/README.md` in compendium.
- **Source of truth:** Document in compendium `README.md`: product repo vs `~/.cursor` vs compendium mirror (avoid silent edit drift).

## 2. Directory conventions (config repo, e.g. `dotfiles/cursor/`)

| Path | Role |
| --- | --- |
| `docs/` | Durable guides (MULTIROOT, lifecycle, etc.). |
| `attic/` | Long-term **ephemeral** or junk-adjacent files—**move**, do not delete; `README.md` explains retention. |
| `.context/` (optional) | `intent.md`, `decisions/` for symlink vs copy policy and compendium path. |
| `compendium/` | **Scaffold** for sibling repo (layout, scripts, registry docs)—not the live sibling unless you intentionally nest. |

Keep canonical tracked keys (`keybindings.json`, `settings.json`, `.cursor/rules/` if present) at expected paths—not under `attic/`.

## 3. Skills provenance (three classes)

Record in **`skills-registry/`** in the compendium (see [skills-registry/README.md](/Users/me/dotfiles/cursor/compendium/skills-registry/README.md) for schema):

1. **Vendor** — Marketplace, git clone, plugin cache; list in `vendor.yaml` (source URL or path, pin, license if known). Do not commit vendor trees as if authored.
2. **Authored (global)** — `~/.cursor/skills/<name>/` or symlink into a **small private skills repo**; optional **submodule** under compendium `skills-registry/upstream/`.
3. **Project-specific** — `<project>/.cursor/skills/<name>/`; mirror under `mirrors/by-project/<slug>/.cursor/skills/`.

**Slug `<slug>`:** Prefer `github-com-org-repo` from `git remote get-url origin` (sanitized); else short hash of absolute project path—store mapping in `project-index.yaml`.

## 4. Plans: global vs project

| Source | Compendium target |
| --- | --- |
| `~/.cursor/plans` (user-global; forum-reported default) | `plans/global/` via `sync-global-plans.sh` (copy; no `--delete` by default). |
| `<project>/.cursor/plans` | `plans/by-project/<slug>/`. |
| Ephemeral plan tabs | Not mirrored; use Cursor **Save to workspace** and [agent best practices](https://www.cursor.com/blog/agent-best-practices). |

Cross-project index: `plans/project-index.yaml` or generated `INDEX.md` (slug, last sync, origin path).

## 5. Mirrors: `.cursor/` and `.specstory/`

- **`snapshot-project.sh`** rsyncs from a live project into `mirrors/by-project/<slug>/` (rules, hooks, skills, plans subset per script flags).
- If the product repo **already commits** `.cursor/` or `.specstory/`, mirroring is still useful for **backup** and **machine diff**; document precedence (product git wins for PRs; compendium wins for “did I lose local-only files?”).
- **Size tiers for `.specstory/`:** (a) rules + config only, (b) include `.specstory/history` with quota or gitignore large blobs—default conservative; see compendium `.gitignore`.

## 6. Autocommit presets (compendium only)

| Preset | Behavior |
| --- | --- |
| **manual** | Run `scripts/snapshot-all.sh`; user commits in `CURSOR_COMPENDIUM_ROOT`. |
| **daily (default)** | `launchd` example in `launchd/` runs snapshot then `git commit` only if index dirty; message `chore(compendium): daily snapshot YYYY-MM-DD`. |
| **watch** | `fswatch` + debounce (optional; noisy)—document, do not enable by default. |

**Guardrail:** Do **not** auto-commit **`dotfiles/cursor`** (or parent dotfiles) unless the user explicitly opts in with a separate automation and remote—default automation targets **compendium repo only**.

## 7. Sibling repo bootstrap checklist

```text
- [ ] Copy `compendium/` scaffold from dotfiles to sibling path; `git init`; private `gh repo create`; set CURSOR_COMPENDIUM_ROOT
- [ ] Fill `skills-registry/vendor.yaml`, `authored.yaml`, `project-index.yaml` from templates
- [ ] Run `scripts/snapshot-all.sh` once; review `git diff`; commit
- [ ] Install launchd plist (optional) for daily preset; load with `launchctl bootstrap`
- [ ] Add ADR in dotfiles `.context/decisions/` for symlink vs submodule for authored skills
```

## 8. Open risks

- **Secrets / MCP** in `.cursor/` — denylist in snapshot scripts.
- **PII** in SpecStory history — compendium stays private; consider encryption later.
- **Duplicate truth** — README must state which tree is canonical for edits.

## See also

- [bootstrap-new-project](file:///Users/me/.cursor/skills/bootstrap-new-project/SKILL.md) — dry-run vocabulary; product layout.
- [bootstrap-umbrella-client-project](file:///Users/me/.cursor/skills/bootstrap-umbrella-client-project/SKILL.md) — client umbrellas only.
- [MULTIROOT-cursor-lifecycle.md](file:///Users/me/dotfiles/cursor/docs/MULTIROOT-cursor-lifecycle.md) — plans paths and chat history context.
