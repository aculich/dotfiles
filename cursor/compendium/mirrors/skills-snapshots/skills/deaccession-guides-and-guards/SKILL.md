---
name: deaccession-guides-and-guards
description: >-
  Guides and guards for irreversible deaccession (reclaim, sweep, revoke,
  destroy vault item). Use when cleaning abandoned tools, rotating shared
  OAuth, mark-and-sweep, or any delete that agents might over-eagerly run.
  Requires staged confirm and inventory gates — not bare "don't delete".
---

# Deaccession guides and guards

> Capsule first. Inventory second. Irreversible last — and only with an explicit verb.

Serious guide: [`~/pdv/meta/DEACCESSIONING-GUIDE.md`](file:///Users/me/pdv/meta/DEACCESSIONING-GUIDE.md)  
Satire (antipattern pedagogy): [`~/pdv/meta/treatises/deaccessioning-passwordless-paradise.md`](file:///Users/me/pdv/meta/treatises/deaccessioning-passwordless-paradise.md)  
Also: `accidental-data-loss-prevention`, `chaos-containment`, `hot-livewires-preflight`, `stale-tooling-trial`.

## Why bare “don’t delete” fails

Agents often treat soft prohibitions as suggestions under task pressure. This skill uses **AI-safety-style stop-points**: capability separation, explicit verbs, inventory gates, and typed confirmation phrases before irreversible actions.

## Irreversible verbs (only these unlock action)

| Verb | Action |
|------|--------|
| `apply-reclaim` | Delete reclaimable bulk (`target/`, `.devbox`, caches) after capsule |
| `apply-sweep` | Remove marked tree after livewires + capsule clear |
| `apply-revoke` | Revoke/delete **provider** credential (OAuth client, API key) |
| `apply-destroy-vault-item` | Delete 1Password item (prefer status `REVOKED` instead) |

User phrases that are **not** consent: “clean it up”, “get rid of it”, “login works”, “we’re done”, “same-day revoke”.

## Mandatory procedure

```text
1. HALT if the proposed action matches an irreversible verb’s effect
2. CLASSIFY: reclaim | sweep | revoke | destroy-vault-item | none
3. PRECONDITIONS:
   - Capsule / AGENT-BRIEFING exists (or explicit skip for reclaim-only of pure build artifacts)
   - LIVEWIRES triaged; secrets in chaos with notes
   - For apply-revoke: consumer inventory attached; no shared-* tags unless inventory empty
4. PROPOSE: impact, why, exact paths/ids, rollback limits
5. WAIT for typed verb in user message (exact phrase)
6. EXECUTE only that verb’s scope; re-halt if scope expands
```

## Shared-credential stop-point (critical)

If a chaos / ROTATION-PLAN note says `shared-*`, `legacy-reusable-elsewhere`, or `revoke: deferred`:

- **Refuse** `apply-revoke` even if a successor ACTIVE client exists for one tool.
- Point to DEACCESSIONING-GUIDE drain-the-swamp.
- Offer to *extend inventory*, not to revoke.

## AGENTS.md snippet (copy into project roots)

```markdown
## Deaccession guards

Irreversible cleanup requires an explicit verb from the human:
`apply-reclaim` | `apply-sweep` | `apply-revoke` | `apply-destroy-vault-item`.
Shared LEGACY OAuth (`shared-*` / revoke deferred) must not be provider-revoked
when only one consumer rotated. See ~/pdv/meta/DEACCESSIONING-GUIDE.md and
skill deaccession-guides-and-guards.
```

## Chaos vault semantics

- **`chaos`**: transition inventory (LEGACY + ACTIVE trials), not a kill switch
- **`develop`**: durable inject only after graduation
- Intake plaintext (e.g. Downloads JSON): create → op readback diff → **shred immediately**
- **Watchtower**: ACTIVE `expires` +90d = revisit trial; LEGACY shared = `inventory-not-expiry`. Watchtower never authorizes `apply-revoke`.

## Graduation ladder

```text
chaos + Watchtower  →  develop  →  optional Infisical Agent Vault / Doppler / Vault / cloud SM
```

See [`~/pdv/meta/notes/2026-07-18-agentic-secrets-landscape.md`](file:///Users/me/pdv/meta/notes/2026-07-18-agentic-secrets-landscape.md). Stay 1Password-centered for personal transition unless the user commissions a peer vault.

## Checklist before claiming “deaccessioned”

- [ ] Capsule preserved
- [ ] Chaos items annotated (successor links; revoke status honest)
- [ ] ROTATION-PLAN matches reality (`deferred` ≠ `revoked`)
- [ ] Irreversible step used an explicit verb
- [ ] No shared LEGACY revoked without empty consumer inventory
