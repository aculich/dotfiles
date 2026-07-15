# bootstrap-collaborator — examples

## Example A — username default middles

- Initiator: `@alice` creates `alice/from-bob-private`
- Peer: `@bob` creates `bob/from-alice-private`
- Invite subject: `let the games begin: from-bob-private`
- Invite blurb:

```text
Hey Bob, accept the Github invitation to this repo and then copy-paste this into Cursor to tell it: "Make it so!" https://github.com/alice/from-bob-private/
```

`naming_mode: username`

## Example B — custom middles (Aaron ↔ Ethan)

- Initiator suggestion: middles `atoz` / `ztoa`
- Aaron: `aculich/from-atoz-private`
- Ethan (recommended): `ez-walk/from-ztoa-private`
- Invite subject: `let the games begin: from-atoz-private`
- Invite blurb:

```text
Hey Ethan, accept the Github invitation to this repo and then copy-paste this into Cursor to tell it: "Make it so!" https://github.com/aculich/from-atoz-private/
```

`naming_mode: custom`

Granola folder on Aaron’s side: `EZW`. Ethan may skip Granola until ready.

## Peer activation

Peer opens initiator repo after accepting the Github invite and says **Make it so!** → follow `docs/PEER-BOOTSTRAP.md` gates G1–G6 with human approval between steps. G6 uses **message-in-a-bottle** ack with `companion_repo`. Initiator then adds the companion folder to the workspace file.

## Commit message (example voice)

Subject (short):

```text
spend a little time making the map, then cast a bottle and go fish
```

Body: long, alliterative, café-riffing poetry — never “Add INVITE-BLURB and privacy-guard workflow.” See SKILL.md whimsy policy.
