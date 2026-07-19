---
name: peeq-cidr-meeting
description: Dual-hat peeq+CiDR — create a CiDR Zoom link (no passcode), put an event on the AALLC PEEQ secondary calendar titled "Zoom for " + title, invite only the dry-run guest (default aculich@berkeley.edu) with other emails in the description, and draft (do not send) mail prefer From aaron@peeq-work.com for gov/enterprise (optional aaron@peeq.work for friendly). Use when the user asks for peeq-cidr-meeting, peeq Zoom shadow, aaron@peeq.work / peeq-work.com invite with CiDR Zoom, or peeq+cidr dual-hat.
---

# peeq-cidr-meeting (dual-hat)

Canonical source: `~/tools/google-workspace-tools/.cursor/skills/peeq-cidr-meeting/`  
Global install: `just peeq-cidr-meeting-install`  
Identity model: [docs/aallc-multi-domain-identity.md](../../../docs/aallc-multi-domain-identity.md)

## Identities

| Step | Identity | Tool |
|------|----------|------|
| Create CiDR Zoom | `aaron@cidrlab.org` | S2S / `user-zoom` `create_meeting` |
| Shadow calendar | AALLC **pCal** (PEEQ secondary) | `gog-as aallc calendar create <PEEQ_CAL_ID>` |
| Title | `"Zoom for "` + meeting title | trailing space in prefix is required |
| Invitees (dry-run) | **only** `aculich@berkeley.edu` | intended guests in description only |
| Invitees (real) | meeting guests (e.g. Miroo) + `aaron@asemicarche.com` as needed | still use pCal; peeq `--from` for alt-Zoom draft |
| Draft | `gog-as aallc` mailbox; prefer `--from aaron@peeq-work.com` (gov); optional `aaron@peeq.work` | **do not send** |

**PEEQ calendar id:**

`c_6432308bf58d6714d4091f7771e1aac2dc43a4f66b13d68edfd2196cadf37a5f@group.calendar.google.com`

Organizer on that calendar is the PEEQ group calendar (creator = `aaron@asemicarche.com`), not a peeq address. True peeq organizer needs a dedicated user — see architecture ladder in the identity doc.

## Zoom

Same as berkeley-cidr-meeting: CiDR S2S, no passcode, WR follow portal. See [reference.md](reference.md).

Preflight: `get_account_profile` = CiDR Lab / `aaron@cidrlab.org`. Wrong tenant → stop and ask.

## Checklist

```
Task Progress:
- [ ] 1. Confirm title / timeslot / intended guests (Miroo list in reference if relevant)
- [ ] 2. Confirm Zoom S2S is CiDR Lab
- [ ] 3. create_meeting (no passcode)
- [ ] 4. Verify join URL has no pwd=
- [ ] 5. gog-as aallc calendar create on PEEQ cal (Zoom for …)
- [ ] 6. Draft alt-Zoom mail (prefer --from aaron@peeq-work.com); do not send
- [ ] 7. Report Zoom URL, event link, draft id, organizer observed
```

### Calendar create

```bash
PEEQ_CAL='c_6432308bf58d6714d4091f7771e1aac2dc43a4f66b13d68edfd2196cadf37a5f@group.calendar.google.com'
gog-as aallc calendar create "$PEEQ_CAL" \
  --summary 'Zoom for <TITLE>' \
  --from '<START>' --to '<END>' --timezone America/Los_Angeles \
  --location '<JOIN_URL>' \
  --description '<DESC>' \
  --attendees 'aculich@berkeley.edu' \
  --json --results-only
```

### Draft

```bash
# Prefer peeq-work.com for gov/enterprise; use peeq.work for friendly recipients
gog-as aallc gmail drafts create \
  --to 'aculich@berkeley.edu' \
  --from 'aaron@peeq-work.com' \
  --subject 'alt-Zoom link for <TITLE>' \
  --body '...'
```

If Gmail fails with `unauthorized_client` while `auth_preferred=service_account`: **pause and ask** (AGENTS.md). Likely DWD Gmail JWT gap — reauth user OAuth (`just auth-reauth-run aallc`) and/or temporarily unset SA for mailbox Gmail, then restore SA from 1Password (`GCP SA JSON — aallc-ws-auto`). Do not invent From headers.

If `--from` fails with `not verified (status: pending)`: open Gmail Accounts settings for human verification; draft without `--from` and state intended From in the body until verified. Verify both peeq.work and peeq-work.com when needed.

## Failure policy

Auth / fingerprint / OAuth: `open` browser or ask human; wait. No alternate vaults or fake tokens.

## Miroo (later real send)

See [reference.md](reference.md). Do not email Miroo unless Aaron explicitly asks.
