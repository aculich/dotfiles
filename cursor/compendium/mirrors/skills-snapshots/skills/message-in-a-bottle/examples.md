# message-in-a-bottle — examples

## Initiator ping (at bootstrap)

`bottles/outbox/2026-07-14T184500Z_entanglement-ping_aculich.md`:

```markdown
---
bottle_id: 019b8c00-atoz-ping-0001
entanglement: aculich/from-atoz-private|ez-walk/from-ztoa-private
from_github: aculich
to_github: ez-walk
created_at: 2026-07-14T18:45:00Z
kind: ping
in_reply_to: null
companion_repo: https://github.com/aculich/from-atoz-private
phase: v0-plaintext
---

# Entanglement offered

Casting a bottle. When your `from-ztoa-private` exists, ack with your companion_repo URL.
```

## Peer ack (after Make it so! G5)

```markdown
---
bottle_id: 019b8c00-ztoa-ack-0001
entanglement: aculich/from-atoz-private|ez-walk/from-ztoa-private
from_github: ez-walk
to_github: aculich
created_at: 2026-07-15T01:00:00Z
kind: ack
in_reply_to: 019b8c00-atoz-ping-0001
companion_repo: https://github.com/ez-walk/from-ztoa-private
phase: v0-plaintext
---

# Entanglement ack

Peer shore online. Companion repo ready. Please add to your workspace.
```
