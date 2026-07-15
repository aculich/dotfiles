---
name: bootstrap-collaborator
description: >-
  Bootstraps bi-directional collaborator repo pairs (from-*-private entanglement),
  workspaces, curated people.md, Granola wiring, TIL, Make it so! peer handoff,
  and first message-in-a-bottle ping/ack. Use when starting a peer collab, peer
  says Make it so!, or companion repo URL arrives. Not for client umbrellas.
disable-model-invocation: true
---

# Bootstrap collaborator

Peer collaboration kit: **two private GitHub repos** (one per person) forming an **entanglement**, mutual **Write/Maintain**, shared `.context/`, optional Granola, TIL, workspaces, and **message-in-a-bottle** for first-ack and ongoing drops. **Not** a client umbrella.

## Execution contract

Same gate as `bootstrap-new-project` §0:

- **Existing** repos: dry-run first (`[plan]` actions → `NO FILES WRITTEN — DRY RUN ONLY`).
- **Apply** only on `bootstrap apply` / `approve bootstrap` / `execute the bootstrap plan` / same-message `apply`|`execute`|`go ahead`, or greenfield + apply.
- **Peer path:** **`Make it so!`** = peer apply intent → `docs/PEER-BOOTSTRAP.md`, gates G1–G6 with human stops.
- **Companion arrived:** when a bottle ack or human paste gives the peer repo URL → run **entanglement complete** (workspace + conventions + inbox).

## Paths

| Path | Who | What |
|------|-----|------|
| **Initiator** | Creates first repo | Scaffold, INVITE-BLURB, PEER-BOOTSTRAP, workspace, **ping bottle**, invite peer Write |
| **Peer** | After invite | Create symmetric repo, scaffold, invite initiator, **ack bottle** (G6) |
| **Entangle** | Initiator after ack | Clone companion, inbox bottle, update workspace folders, `entanglement_status: entangled` |

Ship skills in-repo: `.cursor/skills/bootstrap-collaborator/` **and** `.cursor/skills/message-in-a-bottle/`.

## Naming

| Piece | Rule |
|-------|------|
| Prefix | `from-` |
| Suffix | `-private` |
| Middle | initiator-suggested pair, else counterpart GitHub username |

See [reference.md](reference.md) for easter-egg middles (agents only; never in invite blurbs).

## Workspaces

1. Ensure `~/projects/` and `~/projects/workspaces/` exist; write `workspaces/README.md` if missing.
2. Create `~/projects/workspaces/<slug>.code-workspace` with the initiator folder only at first:

```json
{
  "folders": [
    { "name": "<initiator-dirname>", "path": "../<initiator-dirname>" }
  ],
  "settings": {
    "files.exclude": { "**/node_modules": true, "**/.venv": true }
  }
}
```

3. When companion ack arrives: `gh repo clone` into `~/projects/<peer-dirname>/` if needed; **append** a second folder entry for the companion; set `entanglement_status: entangled` in conventions.

## Entanglement + message-in-a-bottle

Chain: this skill creates the pair; **`message-in-a-bottle`** carries the first ping/ack.

| Step | Actor | Action |
|------|-------|--------|
| Offer | Initiator apply | Write `bottles/outbox/…_entanglement-ping_….md` (`kind: ping`); `entanglement_status: offered` |
| Ack | Peer G6 | Write ack bottle with `companion_repo` = their HTTPS URL; push; optional OOB notify |
| Complete | Initiator | Receive bottle → update workspace + conventions → `entangled` |

Full bottle schema: skill `message-in-a-bottle`.

## Initiator checklist (apply)

```
- [ ] Private from-<middle>-private remote; clone ~/projects/<repo>/
- [ ] ~/projects/workspaces/ + README + <slug>.code-workspace (initiator only)
- [ ] Scaffold kit (below) including bottles/ + both skills
- [ ] Curate .context/people.md
- [ ] Wire Granola if provided
- [ ] PEER-BOOTSTRAP.md + INVITE-BLURB.txt
- [ ] Ping bottle in bottles/outbox/
- [ ] just doctor; commit; push; invite peer (push/Write on user repos)
```

## Peer checklist (`Make it so!`)

**STOP — \<PeerName\> review required before continuing** after each dry-run.

| Gate | Prepare | Human before |
|------|---------|--------------|
| G1 | Create private peer repo + clone path | `gh repo create` |
| G2 | Write invites both ways | Running invites |
| G3 | Peer people.md essentials | Commit |
| G4 | Granola or skip | Conventions write |
| G5 | First push plan | `git push` |
| G6 | **message-in-a-bottle** ack + optional OOB notify | Sending / pushing bottle |

Also: peer workspace file under `~/projects/workspaces/` (their slug or shared slug with both folders once initiator URL known).

## Directory skeleton

```
.gitignore
README.md
AGENTS.md
justfile
docs/AUTOMATION.md
docs/PEER-BOOTSTRAP.md
docs/INVITE-BLURB.txt
.context/
incoming/
bottles/{outbox,inbox,ack}/README.md
granola/<FolderName>/     # optional
til/
notes/
.github/workflows/privacy-guard.yml
.cursor/skills/bootstrap-collaborator/
.cursor/skills/message-in-a-bottle/
```

## Contacts curation

Approved share lists only → `.context/people.md`. Hard exclude addresses, insurance, unapproved emails. `just contacts-pull` when `gog` available. No personal Contacts janitor work in this skill.

## Invite blurb

**Email subject:**

```text
let the games begin: <reponame>
```

**Body** (also SMS-safe one-liner):

```text
Hey <PeerFirstName>, accept the Github invitation to this repo and then copy-paste this into Cursor to tell it: "Make it so!" <InitiatorRepoHTTPS>/
```

→ `docs/INVITE-BLURB.txt` (Subject line + blank line + body)

## Commit messages (whimsy required)

Do **not** write practical, informative commit messages — they are mundane, predictable, and pedestrian.

| Part | Rule |
|------|------|
| **Short subject** | Chuckle-worthy, cryptic, or otherwise absurd. Never a changelog. |
| **Long body** | **Abhor and Abstain from the Tyranny of Prose and instead Appeal to the Absurdly Aphrodisiacal and Alliterative Power of Poetry and Prodigiously Purile Pageantry.** Café voice, prompts-for-humans what-ifs, mutuality; opaque easter eggs allowed — never spoil or explain them. |

Encode this policy in the bootstrapped repo’s `AGENTS.md`.

## Out of scope

Client umbrellas, Contacts hygiene, Granola scrapers, spoiling easter eggs, implementing bottle crypto (roadmap in message-in-a-bottle).

## See also

- [reference.md](reference.md) — workspace JSON, conventions, gates
- [examples.md](examples.md)
- `message-in-a-bottle`, `context-engineering`, `meeting-sync`
