# AGENTS.md — deaccession guards (template)

Copy the block below into a project `AGENTS.md` (or merge into an existing one) when the tree is under mark-and-sweep / credential rotation.

```markdown
## Deaccession guards

Irreversible cleanup requires an explicit verb from the human:
`apply-reclaim` | `apply-sweep` | `apply-revoke` | `apply-destroy-vault-item`.

- Capsule + livewires before sweep.
- Shared LEGACY OAuth (`shared-*` / revoke deferred in chaos or ROTATION-PLAN) must **not** be provider-revoked when only one consumer rotated.
- Plaintext Downloads secrets: vault intake → verify → shred immediately.

Canonical: ~/pdv/meta/DEACCESSIONING-GUIDE.md
Skill: ~/.cursor/skills/deaccession-guides-and-guards/
Satire (why this exists): ~/pdv/meta/treatises/deaccessioning-passwordless-paradise.md
```
