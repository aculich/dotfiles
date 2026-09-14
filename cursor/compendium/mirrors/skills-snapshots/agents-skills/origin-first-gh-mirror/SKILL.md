---
name: origin-first-gh-mirror
description: >-
  Clone a Cursor Origin-hosted repo (Start from scratch / Agents Window
  cloud-only project / origin.cursor.com) to a local directory and add a
  private GitHub backup remote named github. Push Origin first, then GitHub.
  Use when the user says Origin-first, Start from scratch, clone this Origin
  repo locally, mirror Origin to private GitHub, dual-remote origin+github, or
  keep GitHub in sync from an Origin-hosted source of truth, or just sync
  that pulls Origin then dual-pushes. Do not use official Sync from GitHub
  (that creates a second Origin listing; it does not attach GitHub to an
  Origin-hosted repo).
license: MIT
compatibility: >-
  Cursor Agent. Requires origin CLI (vendor origin skill), git, gh.
  disabled-environments: none for local; do not run origin repo delete.
metadata:
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
  author: aculich
  playbook: ~/dotfiles/cursor/docs/cursor-origin-github-backup.md
---

# Origin-first local checkout + private GitHub backup

Official Cursor **mirror** is GitHub → Origin only, with **GitHub as source of
truth**. This skill is the other direction: an **Origin-hosted** repo is SoT.
Clone it locally, then keep a **private** GitHub backup on a remote named
`github`. Always dual-push from the local copy (Origin first). Install
`just sync` in the clone (pull Origin ff-only, then push both). Never use
official **Sync from GitHub** here: it does not attach to an existing
Origin-hosted repo; it adds a second GitHub-SoT listing.

Playbook: `~/dotfiles/cursor/docs/cursor-origin-github-backup.md`.

Vendor skills (read, do not edit): `~/.cursor/skills-cursor/origin/SKILL.md`
for CLI install/auth. `new-repo` / `share` create Origin from a local project
(opposite start) and must not rewrite remotes.

## Hard limits

- Never run `origin repo delete` unless the user named that exact repo and
  confirmed deletion in this conversation.
- Never replace, rename, or rewrite an existing git remote URL.
- Never run official **Sync from GitHub** / Origin inbound mirror for a repo
  this skill is backing up. That does not attach GitHub to the existing
  Origin-hosted repo; it creates a second listing and flips SoT on the new one.
- Never pass `--remote=origin` (or `--remote origin`) to `gh repo create`.
  The GitHub remote name is always `github`.
- Never create a **public** GitHub repo. Always `--private`.
- Never stage-and-push secrets (`.env*`, key files, credentials). List what
  would be committed first; ask if anything looks secret.
- Do not invoke vendor `new-repo` / `share` when the project already has an
  Origin remote.

## Remotes

| Remote | URL | Role |
| --- | --- | --- |
| `origin` | `https://origin.cursor.com/{owner}/{repo}.git` | Source of truth |
| `github` | `git@github.com:{gh_owner}/{repo}.git` (or HTTPS) | Private backup |

Push order is always **Origin, then GitHub**.

## 1. Origin CLI

Follow the vendor `origin` skill: detect `origin`, install if missing, then
`origin auth status` / `origin auth login`. Do not reinstall a working CLI.

## 2. Inspect before you write remotes

```bash
origin repo list
git rev-parse --is-inside-work-tree 2>/dev/null
git remote -v
```

- If the user named an Origin repo and there is no local checkout yet → clone
  (step 3).
- If already inside a checkout whose `origin` is `origin.cursor.com` and there
  is no `github` remote → skip clone; go to step 4.
- If `origin` already points at GitHub, or a remote named `github` already
  exists → stop. Report the remotes. Do not rewrite them. Offer to
  `git push origin` then `git push github` only if both remotes are already
  the expected pair.
- If this is a **GitHub-mirrored** Origin repo (official Sync from GitHub;
  pushes to the Origin URL land on GitHub) → stop. This skill does not apply.

Default local path: `~/projects/<repo-name>` (lowercase, dashes). Ask only if
the destination is ambiguous or already exists with a different remote.

Default GitHub owner: `gh api user --jq .login`. Ask if the user named an org.

## 3. Clone Origin locally

```bash
origin repo clone <org>/<name>
# or
git clone https://origin.cursor.com/{owner}/{repo}.git
```

Confirm `git remote get-url origin` is `https://origin.cursor.com/...`.

To open in the classic IDE on this machine: `cursor --classic <dir>` (see
`~/dotfiles/cursor/docs/cursor-classic-ide.md`). Agents Window **Open IDE**
opens the current workspace only.

## 4. Create the private GitHub backup

Only if `github` is not already a remote:

```bash
gh repo create "$GH_OWNER/$NAME" --private --source=. --remote=github --push
```

If `gh repo create` fails because the name exists, stop and ask. Do not
retarget remotes.

## 5. Push Origin first, then GitHub

After local commits (or after `gh` created the GitHub repo), always dual-push:

```bash
git push origin HEAD
git push github HEAD
```

Or the helper (from this skill directory):

```bash
scripts/push-both.sh
```

That script refuses to run unless remotes `origin` and `github` both exist. It
does not create or rewrite remotes.

## 6. Install `just sync` in the clone

Copy helpers into the clone (repo-local; do not depend on `~/.cursor/skills/`):

```bash
scripts/install-just-sync.sh /path/to/local-checkout
```

That copies `scripts/origin-gh-sync.sh` (plus `lib-remotes.sh` and
`push-both.sh`) and adds a just recipe:

- No justfile → write a minimal justfile with `sync`
- justfile exists and `just --list` has no `sync` → append `sync`
- `sync` already exists → append `origin-gh-sync` instead and tell the user

`just sync` (or `just origin-gh-sync`) runs `git fetch origin`,
`git pull --ff-only origin <branch>`, then push Origin and GitHub. It
stops if the pull is not a fast-forward. It never pulls from `github`.

## 7. Adding local files later

1. List what would be staged (`git status --porcelain`). Honor `.gitignore`.
2. Ask before staging secrets.
3. Commit.
4. Dual-push (step 5) or `just sync` (step 6).

## Report back

Give the user:

- Local path
- Origin URL and `https://cursor.com/codebase/<org>/<name>`
- GitHub URL (private)
- `git remote -v` (must show `origin` + `github`)
- Which just recipe was installed (`sync` or `origin-gh-sync`)
