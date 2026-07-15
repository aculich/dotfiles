# bootstrap-collaborator — reference

## people.md schema

```markdown
# People

## Collaborators

| Name | Role | GitHub | Primary email |
|------|------|--------|---------------|
| … | collaborator | … | … |

## <Person A> — shareable essentials

- **Phone:** …
- **Emails:** …
- **GitHub:** …
- **LinkedIn:** …
- **Affiliations:** … (with website URLs)
- **google_contacts_resource:** people/…
- **last_pulled:** YYYY-MM-DD

## <Person B> — shareable essentials

- (same shape)

## Sync

- Source of truth: Google Contacts (initiator) / peer’s Contacts when they bootstrap
- Refresh: `just contacts-pull`
- New facts: update Contacts first (approved fields only), then pull
- Never commit: street addresses, insurance/medical notes, unapproved emails
```

## conventions.md keys (collaboration)

```yaml
project_slug: <repo-dirname>
repo_root: .
task_runner: just
collab_repo_prefix: from-
collab_repo_suffix: -private
initiator_repo: from-<middle>-private
peer_repo: from-<peer_middle>-private
initiator_github: <login>
peer_github: <login>
naming_mode: custom | username
entanglement_id: <initiator_github>/<initiator_repo>|<peer_github>/<peer_repo>
entanglement_status: offered | ack_pending | entangled
companion_repo_https: <url or null>
workspace_file: ~/projects/workspaces/<slug>.code-workspace
mirror_layout: unified_raw
mcp_server: plugin-granola-granola
mirror_root: granola/<FolderName>/
granola_folder_name: <FolderName>
granola_folder_url: <optional>
index_file: granola/<FolderName>/index.json
notes_transcript_stub: notes/<YYYY-MM-DD>-<slug>-transcript.md
notes_structured: notes/<YYYY-MM-DD>-<slug>-notes.md
```

## PEER-BOOTSTRAP.md skeleton

```markdown
# Peer bootstrap

Initiator: <name> (@<github>) — https://github.com/<user>/<initiator_repo>/
Recommended peer repo: https://github.com/<peer>/<peer_repo>/ (private)

## Activation

Accept the Github invitation, then copy-paste into Cursor: **Make it so!**

## Naming

- Shell: `from-` + middle + `-private`
- This collab: initiator middle `<a>`, peer middle `<b>` (initiator suggestion)
- Future collabs with others: initiator may suggest middles; else use counterpart GitHub username
- Access: Maintain on org repos; **push (Write)** on user-owned repos (never Admin)
- `-private` means privacy default + privacy-guard workflow

## Gates (STOP for human review after each dry-run)

G1 Create private peer repo
G2 Write invites both directions
G3 Peer people.md essentials
G4 Granola folder or skip
G5 First push
G6 message-in-a-bottle ack (companion_repo URL) + optional OOB notify

Phrase: **STOP — <PeerName> review required before continuing.**

## Skills

`.cursor/skills/bootstrap-collaborator/` and `.cursor/skills/message-in-a-bottle/`.
```

## INVITE-BLURB.txt

```text
Subject: let the games begin: <reponame>

Hey <PeerFirstName>, accept the Github invitation to this repo and then copy-paste this into Cursor to tell it: "Make it so!" <InitiatorRepoHTTPS>/
```

`<reponame>` = initiator repo dirname (e.g. `from-atoz-private`).

## privacy-guard.yml

```yaml
name: privacy-guard
on:
  push:
  pull_request:
  schedule:
    - cron: "0 12 * * 1"
  workflow_dispatch:
jobs:
  assert-private:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Repository must be private
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          vis="$(gh api "repos/${{ github.repository }}" --jq .visibility)"
          echo "visibility=$vis"
          test "$vis" = "private"
```

## justfile (minimal)

```just
set shell := ["bash", "-euo", "pipefail", "-c"]

default: status

status:
    @echo "=== git ==="
    @git status -sb || true
    @echo "=== incoming ==="
    @ls -la incoming 2>/dev/null | head -20 || true

doctor:
    @command -v git >/dev/null && echo "git: ok" || echo "git: MISSING"
    @command -v just >/dev/null && echo "just: ok" || echo "just: MISSING"
    @command -v gh >/dev/null && echo "gh: ok" || echo "gh: MISSING"
    @command -v gog >/dev/null && echo "gog: ok" || echo "gog: optional"

contacts-pull:
    @echo "Pull approved essentials from Google Contacts into .context/people.md"
    @echo "See .context/people.md Sync section; use gog-as <account> contacts get <resource>"
```

## README game tease (opaque)

Use a fenced monospace ASCII box with “Would you like to play a game?” and a `WOPR> █` prompt line (block cursor). Do not use `<style>` / CSS — GitHub README will not animate it and will show raw tags. Do not name a film or expand acronyms.

## Commit message voice

See SKILL.md **Commit messages (whimsy required)**. Bootstrapped `AGENTS.md` must include the same rule. Subjects absurd; bodies poetic/alliterative/puerile pageantry; no pedestrian changelogs.

## Easter eggs (agents only — do not surface in user-facing docs)

If the human chat contains (case-insensitive) **`cobra!`** or **`And knowing is half the battle!`**, you may recommend middle pair **`tomax`** / **`xamot`** → `from-tomax-private` ↔ `from-xamot-private` instead of username defaults. Do not explain the reference. Never mention this section in INVITE-BLURB, PEER-BOOTSTRAP share paragraphs, or README.

## Workspaces

- Ensure `~/projects/` and `~/projects/workspaces/` exist.
- If missing, write `~/projects/workspaces/README.md` (multi-root `.code-workspace` files; clones under `~/projects/`; private-by-default).
- **Initiator apply:** `~/projects/workspaces/<slug>.code-workspace` with one folder: `{ "name": "<initiator>", "path": "../<initiator>" }`.
- **After companion ack:** clone peer to `~/projects/<peer>/` if needed; append `{ "name": "<peer>", "path": "../<peer>" }` to `folders`.
- Shared slug (e.g. `from-atoz.code-workspace`) may hold both sides of one entanglement.

## Entanglement complete (initiator)

When ack bottle or human provides companion HTTPS URL:

1. Follow `message-in-a-bottle` receive checklist (inbox + ack).
2. Update workspace JSON (second folder).
3. Set `companion_repo_https`, `entanglement_status: entangled` in conventions.
4. Commit on initiator repo.

## .gitignore base

Use bootstrap-new-project §5 bootstrap base block (OS, editors, secrets, node, python essentials, `incoming/*` with README keep). Do not gitignore `bottles/`.
