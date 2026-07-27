---
name: bcal-declutter
description: Archive Berkeley Calendar (bCal) guest invites onto Aaron misc as Free copies with resuscitation metadata, then decline the originals with sendUpdates=none so they leave the primary calendar without notifying the organizer. Use when the user asks for bcal-declutter, declutter calendar, decline without notify, mark Free and archive, or move a cluttering invite off the main Berkeley calendar.
---

# bcal-declutter (archive then decline)

Canonical source: `~/tools/google-workspace-tools/.cursor/skills/bcal-declutter/`  
Global install: `just bcal-declutter-install` → symlink under `~/.cursor/skills/`  
Controller briefing: [`briefings/bcal-declutter/AGENT-BRIEFING.md`](../../../briefings/bcal-declutter/AGENT-BRIEFING.md)

## Identities (never mix credentials)

| Step | Email / tool |
|------|----------------|
| All calendar ops | `aculich@berkeley.edu` via `gog-as berkeley` |
| MCP reads (optional) | `user-google-workspace` with `user_google_email=aculich@berkeley.edu` |

**Never** use cidrlab, personal, or other-org calendars for this workflow.

## Defaults

| Item | Value |
|------|--------|
| Source calendar | `primary` |
| Archive calendar | **Aaron misc** — `berkeley.edu_afiqse0vg2tlac6jqp3qgvcnj8@group.calendar.google.com` |
| Archive transparency | `free` (`transparent`) |
| Decline notifications | `sendUpdates=none` |

Override archive calendar only if the user names a different owned secondary.

## Checklist

```
Task Progress:
- [ ] 1. Resolve event(s) on primary (title / id / time window)
- [ ] 2. Dump parent with `gog-as berkeley calendar raw primary <eventId> --json`
- [ ] 3. Create Free archive copy on Aaron misc (RRULE if recurring) + resuscitation metadata
- [ ] 4. Confirm archive exists before any decline
- [ ] 5. Decline primary parent via calendar.events.patch sendUpdates=none
- [ ] 6. Verify primary RSVP=declined; report archive links
```

## Workflow

### 1. Resolve

Prefer parent recurring id when the user points at a series occurrence. Capture: `id`, `iCalUID`, `summary`, `description`, `location`, `start`/`end`, `timeZone`, `recurrence`, `organizer`, `attendees`, `htmlLink`, `transparency`.

If organizer ≠ Tim/self and the user did not explicitly name the invite, **confirm** before declining.

### 2. Archive (owned Free copy)

```bash
MISC='berkeley.edu_afiqse0vg2tlac6jqp3qgvcnj8@group.calendar.google.com'
# RRULE must include the RRULE: prefix for gog create
gog-as berkeley calendar create "$MISC" \
  --summary '…' \
  --from '…' --to '…' --timezone America/Los_Angeles \
  --rrule 'RRULE:FREQ=WEEKLY;…' \
  --transparency=free \
  --location '…' \
  --description "$META_PLUS_ORIGINAL_BODY" \
  --json
```

Prepend a **resuscitation block** to `--description` (see [reference.md](reference.md)). Never decline until create succeeds and returns an event id.

### 3. Decline without notifying

`gog calendar respond` has no `sendUpdates` flag. Use Discovery patch:

```bash
# body: attendees with self responseStatus=declined; keep organizer row
gog-as berkeley api call calendar v3 calendar.events.patch \
  --allow-write --force \
  --params '{"calendarId":"primary","eventId":"<PARENT_ID>","sendUpdates":"none"}' \
  --body @decline-body.json \
  -j
```

Patch the **parent** recurring id for whole-series declutter.

### 4. Report

- Archive event id + htmlLink (Aaron misc)
- Primary self `responseStatus=declined`
- Note: declined events hide from main view unless “Show declined events” is on

## Safety

- Never decline without a successful archive copy.
- Never `sendUpdates=all` for declutter.
- Berkeley-only credentials; refuse cross-org calendar moves.
- Recurring: operate on parent id unless user asks for a single occurrence (`scope=single` patterns).

## First production use

SOC-N100 Summer 2026 class invites (Teaching + Class Zoom Meeting series) — archived Free on Aaron misc, declined primary with `sendUpdates=none` (2026-07-23).
