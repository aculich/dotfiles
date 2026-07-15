---
name: message-in-a-bottle
description: >-
  Passes messages between paired collaborator repos (an entanglement) via
  bottles/ drops, acks, and optional out-of-band notify. Use when bootstrapping
  first-ack after Make it so!, exchanging peer repo URLs, or building toward
  verifiable trust/key exchange. Lightweight by default; crypto is a later phase.
disable-model-invocation: true
---

# Message in a bottle

Cross-repo messaging for a collaborator **entanglement** (two private `from-*-private` repos that acknowledge each other). Homage to entanglement: a message cast from one shore, retrieved on the other.

Start **lightweight** (markdown bottles in-git). Later phases can add cryptographic verification (PGP/age-style key parties) without changing the bottle layout.

## When to use

- Peer finished bootstrap and must ack the initiator (first entanglement)
- Either side needs to send a durable note the other side’s agent can ingest
- Preparing for future signed/encrypted bottles (see [reference.md](reference.md) roadmap)

## Pair with

- **`bootstrap-collaborator`** — creates the entanglement; G6 = first bottle + ack protocol; wires workspaces when companion URL arrives
- **`context-engineering`** — promote durable facts from bottles into `.context/` when appropriate

## Bottle layout

```
bottles/
  README.md
  outbox/                 # sealed here, then pushed
  inbox/                  # copies pulled from companion (or mirrored)
  ack/                    # acknowledgements of received bottles
```

Filename: `YYYY-MM-DDTHHMMSSZ_<slug>_<from-github>.md` (UTC).

## Message schema (v0 — plaintext)

```markdown
---
bottle_id: <uuid or ulid>
entanglement: <initiator_repo>|<peer_repo>   # e.g. aculich/from-atoz-private|ez-walk/from-ztoa-private
from_github: <login>
to_github: <login>
created_at: <ISO-8601>
kind: ping | ack | notify | note | key_offer   # key_offer reserved for later
in_reply_to: <bottle_id or null>
companion_repo: <https://github.com/…/… or null>
phase: v0-plaintext
---

# <subject>

<body>
```

Never put secrets in v0 bottles. Future signed/encrypted payloads use `phase: v1-…` (reference).

## First entanglement (bootstrap handoff)

After peer pushes their repo (**bootstrap-collaborator** G5):

1. **Peer** writes `bottles/outbox/…_entanglement-ack_<peer>.md` with `kind: ack`, `companion_repo` = their new HTTPS URL, `in_reply_to` = initiator’s ping bottle id if present.
2. Peer pushes; optionally also sends a short human SMS/email (out-of-band).
3. **Initiator** (on notify or next session): clone/fetch companion → copy bottle into `bottles/inbox/` → write `bottles/ack/…` → update `~/projects/workspaces/<slug>.code-workspace` to add companion folder → update `.context/conventions.md` `peer_repo` / entanglement status → commit.

Initiator should leave a **ping** bottle in `bottles/outbox/` at bootstrap time so the peer has something to ack (`kind: ping`, subject “entanglement offered”).

## Agent checklist — send

```
- [ ] Confirm entanglement ids (both repo full names)
- [ ] Draft bottle in bottles/outbox/ (schema above)
- [ ] Human review if kind != ping/ack routine
- [ ] git add + commit + push
- [ ] Optional: tell human the one-line notify to send OOB
```

## Agent checklist — receive

```
- [ ] Locate companion repo URL (bottle, PEER-BOOTSTRAP, or human paste)
- [ ] Fetch companion bottles/outbox (clone or gh api raw)
- [ ] Copy new bottles into bottles/inbox/ (do not rewrite history of companion)
- [ ] Write bottles/ack/… confirming bottle_id
- [ ] If companion_repo present: update workspace + conventions (see bootstrap-collaborator)
- [ ] Promote durable facts to .context/ only when human agrees
```

## Out of scope (v0)

- Implementing encryption/signing (document roadmap only)
- Replacing email/SMS for human urgency — bottles are durable; OOB is optional signal
- Auto-merging untrusted companion git history into your main (inbox copy only)

## See also

- [reference.md](reference.md) — entanglement id, workspace update, crypto roadmap
- [examples.md](examples.md) — ping / ack examples
- Skill `bootstrap-collaborator` — creates entanglement and first ping
