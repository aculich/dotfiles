---
name: ern-cidr-mail
description: Dual-hat ERN↔CiDR mail — resolve auspice, pick From hat from the matrix, draft (do not send) via the correct identity, optionally notify the other side. Use for HPRM data-request replies, ERN outreach drafts, or when the user asks for ern-cidr-mail / dual-hat mail between berkeley and cidrlab.
---

# ern-cidr-mail (dual-hat draft)

Canonical source: `~/tools/google-workspace-tools/.cursor/skills/ern-cidr-mail/`  
Global install: `just ern-cidr-mail-install` → symlink under `~/.cursor/skills/`

## Identities (never mix credentials)

| Step | Hat / email | Tool |
|------|-------------|------|
| Resolve auspice | Project attach (`projects.ern`) or user phrase | `.workspace-tools.json` / registry |
| Draft requester-facing ERN mail | `berkeley-spa-ern` → `evictions@berkeley.edu` | `just mail-draft-as` or MCP `draft_gmail_message` |
| Optional notify / collab | `cidrlab-aaron` / Tim berkeley | Draft CC or separate notify — **not** From for requesters |
| CiDR contract delivery | `cidrlab-*` only | Never `@berkeley.edu` From |

Hard rule: **UCB resources never for CiDR delivery.** Inverse for public HPRM: **never cidrlab From** to data requesters.

Out of scope: NSF POSE / BIDS LoS (use RRID attach + [docs/notes/2026-07-16-bids-rrid-ern-pose-connection.md](../../../docs/notes/2026-07-16-bids-rrid-ern-pose-connection.md)).

## Checklist

```
Task Progress:
- [ ] 1. Resolve auspice (ERN vs CiDR) from attach or user
- [ ] 2. Pick From hat from From matrix
- [ ] 3. Confirm SPA token (`gog-as evictions` / `just ern`) if using berkeley-spa-ern
- [ ] 4. Create draft only (mail-draft-as or MCP) — do not send
- [ ] 5. Optional: CC/notify other-side principal
- [ ] 6. Report draft id / mailbox / hat used
```

### 1–2. Auspice and From

| Scenario | From hat |
|----------|----------|
| HPRM / public ERN reply | `berkeley-spa-ern` |
| ERN internal | `berkeley-ern` |
| CiDR contract | `cidrlab-aaron` or `cidrlab-admin` |

### 3–4. Draft

Prefer CLI (verifies account routing):

```bash
just mail-draft-as berkeley-spa-ern \
  --to 'requester@example.org' \
  --subject 'HPRM data request' \
  --body '…'
```

When SPA gog token is missing, `mail-draft-as` will fail rather than silently fall back (hat status is live). Report clearly; do not draft as cidrlab.

**Do not send.**

### 5. Notify

Optional CC Tim/Aaron berkeley or cidrlab for triage — porous notify per `related_orgs`. Never change From to cidrlab for requester mail.

## Failure policy

- Auth / SPA not ready: fall back per `mail-draft-as.sh` warning; report clearly.
- Wrong tenant / misrouted MCP: stop; prefer `gog-as` / `mail-draft-as`.
- User asks to auto-send: refuse; draft only unless they send manually.

## Install

```bash
just ern-cidr-mail-install
```
