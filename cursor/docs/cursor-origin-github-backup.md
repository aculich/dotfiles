# Origin-first local checkout + private GitHub backup

**Date:** 2026-09-13  
**Status:** Field playbook. Prefer official Origin docs when product behavior drifts.

Origin is Cursor’s git forge (`origin.cursor.com`, early beta on paid plans). A project started in the Agents Window with **Start from scratch** is **Origin-hosted**, not a GitHub repo. Official “mirror” is **GitHub → Origin only**. This note is the **other** direction: clone Origin locally, then keep a private GitHub backup with named remotes.

**Skill:** `origin-first-gh-mirror` (SoT: `~/projects/agent-skills/skills/.curated/origin-first-gh-mirror/`).  
**Vendor skills (do not edit):** `~/.cursor/skills-cursor/origin`, `new-repo`, `share`.

**Official entry points:**

- [Origin](https://cursor.com/docs/origin)
- [Create an Origin repository](https://cursor.com/docs/origin/create-repository)
- [Clone, Push & Pull](https://cursor.com/docs/origin/git)
- [Mirror a GitHub repository](https://cursor.com/docs/origin/mirror-github) (GitHub stays source of truth)
- [Origin settings](https://cursor.com/docs/origin/settings) (no Attach GitHub; Origin-hosted repos have no Sync Status)
- [Origin CLI](https://cursor.com/docs/origin/cli)
- [Agents Window](https://cursor.com/docs/agent/agents-window)
- [Cloud Agents](https://cursor.com/docs/cloud-agent)
- Changelog: [Origin Code Hosting](https://cursor.com/changelog/origin-code-hosting) (2026-08-17), [Start from scratch](https://cursor.com/changelog?page=5) (2026-08-27)

---

## 1. Three surfaces

These are complementary, not three copies of the same app.

| Surface | What it is | How you get there |
| --- | --- | --- |
| **Classic IDE** | Editor, extensions, multi-file layout | Command Palette **Open IDE**; on this machine `cursor --classic` ([cursor-classic-ide.md](cursor-classic-ide.md)) |
| **Agents Window** | Agent-first UI for local, cloud, SSH, worktrees; multi-workspace and local↔cloud handoff (`/in-cloud`, `/autopilot`) | Command Palette **Open Agents Window** |
| **Origin** | Cursor-hosted git at `https://origin.cursor.com/{owner}/{repo}.git` | [cursor.com/codebase](https://cursor.com/codebase) |

**Start from scratch (cloud-only new project):** Agents Window / [cursor.com/agents](https://cursor.com/agents) → repo picker **Start from scratch** → prompt a cloud agent. Cursor creates an Origin repo in the background; **Create repo** names it private or internal. That is Origin-hosted. GitHub is not in the path.

**Open IDE** opens the *current* workspace. If the cloud project is not on disk yet, clone first, then open that folder.

---

## 2. Two hosting models (do not mix them)

| Kind | How it starts | Source of truth | `git push` to `origin.cursor.com/...` |
| --- | --- | --- | --- |
| **Origin-hosted** | Start from scratch, **New** on codebase, or `origin repo create` | **Origin** | Lands on Origin. GitHub is absent unless you add it. |
| **GitHub-mirrored** | **Sync from GitHub** | **GitHub** | Goes **to GitHub**. Origin updates after GitHub accepts. |

Using **Sync from GitHub** after an Origin-first project does **not** attach GitHub to the repo you already have (see §4a). Do not do that for this workflow.

Official “keep GitHub and Origin in parallel while you evaluate” adds **two push URLs on one remote** ([Clone, Push & Pull](https://cursor.com/docs/origin/git)). Fetch/pull stay confusing. Prefer **named remotes**:

- `origin` → `https://origin.cursor.com/{owner}/{repo}.git` (source of truth)
- `github` → private GitHub repo (backup)

---

## 3. Local clone (official)

1. Install and sign in with the vendor `origin` skill (`origin auth login` sets the git credential helper).
2. List, then clone:

```bash
origin repo list
origin repo clone <org>/<name>
# or
git clone https://origin.cursor.com/{owner}/{repo}.git
```

3. Open the folder in the classic IDE (`cursor --classic <dir>`).

Vendor `new-repo` / `share` go the other way (local project → create Origin → push). They refuse if a remote already exists.

---

## 4. Private GitHub backup (emerging, not official)

There is no product auto-sync from Origin to GitHub. Cursor Automations run cloud agents; they are not a git mirror. GitHub Actions have no Origin credentials by default.

```bash
# origin CLI already authenticated; repo already cloned
cd /path/to/local-checkout
gh repo create "$GH_OWNER/$NAME" --private --source=. --remote=github --push
git push origin HEAD
git push github HEAD
```

Later: commit locally, then push **Origin first**, GitHub second. Ongoing sync from the clone:

```bash
just sync
# pull --ff-only from Origin, then push origin and github
```

That recipe lives in the **cloned project** (collision-safe: if `sync` is already taken, the skill adds `origin-gh-sync` instead). The skill installer copies helpers into the clone:

```bash
~/projects/agent-skills/skills/.curated/origin-first-gh-mirror/scripts/install-just-sync.sh /path/to/local-checkout
```

**Do not:**

- Run **Sync from GitHub**
- Rewrite the existing `origin` remote
- Pass `--remote=origin` to `gh repo create`
- Create a public GitHub repo
- Run `origin repo delete` unless the user named that exact repo and confirmed

---

## 4a. Will official sync attach a GitHub repo created after Origin?

**No.** Official sync will not convert or attach to an existing Origin-hosted repo.

[Origin settings](https://cursor.com/docs/origin/settings): **Sync Status** exists only on repos mirrored from GitHub. “Repositories created on Origin do not show sync status.” There is **Detach from GitHub** (mirrored → standalone Origin-hosted). There is **no Attach GitHub**.

**Sync from GitHub** copies a GitHub repo *into* Origin as a **new mirrored listing**. GitHub stays SoT; pushes to that listing’s clone URL go to GitHub ([Mirror a GitHub repository](https://cursor.com/docs/origin/mirror-github)).

If you Start from scratch, later `gh repo create` a private GitHub copy, then click **Sync from GitHub**, you get a **second** Origin entry (GitHub-SoT). The original Origin-hosted repo stays Origin-SoT with no sync status. Cloud agents on the original still push to Origin; on the new listing they open GitHub PRs. Histories can diverge.

Keep named remotes and dual-push from the local clone. Do not rewrite `origin` to GitHub to “make GitHub primary.”

---

## 5. Cloud vs local (short)

Full notes: [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md).

- **Cloud:** many agents in parallel, laptop off, isolated VM (build/test/browser), Start from scratch without GitHub, warm **Builds** (faster first token, no extra Build fee). Billed at API pricing for the selected model; spend limit on first use. Auto-run + default internet. No `~/.cursor` hooks/MCP unless wired into the cloud env. **Move to Cloud** does not take uncommitted local files.
- **Local:** dirty tree, approval-gated shell, machine tools / `just` / global skills, tight IDE loop, included Cursor Models pool.
- **Speed:** local wins short edit loops; cloud wins ready-Build cold start + many long parallel runs. Same model tokens cost the same per million; cloud adds spend-limit friction and unattended burn, not a documented VM surcharge.

Practical split: explore in cloud + Origin; clone locally when you need files, classic IDE, or a GitHub-visible backup; keep pushing Origin first.

---

## 6. Related

- [cursor-classic-ide.md](cursor-classic-ide.md)
- [agents-window-hygiene.md](agents-window-hygiene.md)
- [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md)
- Vendor Origin CLI skill: `~/.cursor/skills-cursor/origin/SKILL.md`
