# berkeley-cidr-meeting reference

## Zoom `create_meeting` settings payload

Shared preferred defaults: [docs/cidrlab-setup.md — Zoom (CiDR Lab)](../../../docs/cidrlab-setup.md#zoom-cidr-lab).

Match Schedule Options defaults (passcode OFF; Waiting Room → Follow Zoom web portal setting):

```json
{
  "user_id": "aaron@cidrlab.org",
  "topic": "<MEETING-TITLE>",
  "type": 2,
  "start_time": "YYYY-MM-DDTHH:MM:SS",
  "duration": 60,
  "timezone": "America/Los_Angeles",
  "settings": {
    "host_video": true,
    "participant_video": true,
    "audio": "both",
    "join_before_host": true,
    "mute_upon_entry": true,
    "waiting_room": false,
    "meeting_authentication": false,
    "auto_recording": "cloud",
    "approval_type": 2
  }
}
```

Notes:

- Omit `password` entirely (passcode OFF).
- `waiting_room: false` matches portal intent when portal WR is off. Account may still force WR on created meetings; PATCH meeting settings if needed, then re-GET to verify.
- Before create: ensure account/user `require_password_for_scheduling_new_meetings` is `false` (needs `account:update:settings:admin` / `user:update:settings:admin` on S2S).
- After create, confirm `join_url` has **no** `pwd=` and `password` is empty.

Official MCP (Hub/search) is separate — see `~/projects/zoom-deeplistening-agents/ZOOM-OFFICIAL-MCP.md`.

## cCal description template

```
CiDR Zoom (alt link for this shadow invite):
<JOIN_URL>

Berkeley source event:
<htmlLink>

Participants (from bCal — listed here only; not invited on cCal):
- <email1>
- <email2>
…

--- plain metadata ---
cCal_title: Zoom for <summary>
bCal_title: <summary>
event_id: <id>
iCalUID: <iCalUID>
htmlLink: <htmlLink>
start: <start>
end: <end>
organizer: <organizer.email>
creator: <creator.email>
recurringEventId: <recurringEventId or none>
bCal_location: <original location>
attendees: <comma-separated emails>

--- json metadata ---
```json
{ … full subset of bCal fields … }
```
```

JSON metadata should include at least: `id`, `htmlLink`, `iCalUID`, `summary`, `start`, `end`, `organizer`, `creator`, `attendees` (email + responseStatus), `location`, `recurringEventId`, `status`, `etag`.

**cCal event title:** `"Zoom for "` (verbatim, including the trailing space) concatenated with the bCal `summary`. Do not alter spacing.

**Attendees field on the API call:** only `aculich@berkeley.edu`.

## bMail draft template

```
To: <organizer.email>
Subject: alt-Zoom link for <MEETING-TITLE>

Hi <name or organizer>,

Please use this as the Zoom link for the calendar invite you created
("<MEETING-TITLE>"):

<JOIN_URL>

This is a CiDR Lab Zoom link (no passcode). Happy to adjust timing or
hosts if needed.

Thanks,
Aaron
```

Leave as **draft** in bMail (`aculich@berkeley.edu`). Do not send.

## Dual-hat policy pointers

- Controller: `~/tools/google-workspace-tools`
- Hat table: `docs/academic-enterprise-operational-guide.md`
- Registry: `config/org-registry.json` → `related_orgs` dotted-line (never share vaults/OAuth)
- Allowed cross for this pattern: shadow calendar + CiDR Zoom alt-link for Berkeley-owned meetings
