# bcal-declutter reference

## Aaron misc calendar

| Field | Value |
|-------|--------|
| Summary | Aaron misc |
| Calendar ID | `berkeley.edu_afiqse0vg2tlac6jqp3qgvcnj8@group.calendar.google.com` |
| Access | owner (`aculich@berkeley.edu`) |

List calendars: `gog-as berkeley calendar calendars --json`

## Resuscitation metadata template

Prepend to the archive event description:

```
=== bcal-declutter ARCHIVE / RESUSCITATION ===
Archived: <RFC3339 UTC>
Source calendar: primary (aculich@berkeley.edu)
Archive calendar: Aaron misc (berkeley.edu_afiqse0vg2tlac6jqp3qgvcnj8@group.calendar.google.com)
Original event id: <id>
Original iCalUID: <iCalUID>
Original organizer: <email>
Original htmlLink: <url>
Original transparency: opaque|transparent
Original recurrence: [<RRULE…>]
Original attendees:
  - <email> (responseStatus=…, self=…, organizer=…)
To resuscitate: ask organizer to re-invite, or recreate from this archive on primary and Accept.
This copy is owned by Aaron (Free). Declining the original used sendUpdates=none.
=== END ARCHIVE METADATA ===

<original description>
```

## Decline body example

```json
{
  "attendees": [
    {"email": "aculich@berkeley.edu", "responseStatus": "declined"},
    {"email": "organizer@berkeley.edu", "organizer": true, "responseStatus": "accepted"}
  ]
}
```

Include every original attendee row you intend to preserve; patch replaces the attendees list semantics—keep the organizer accepted.

## gog flags that matter

| Command | Flags |
|---------|--------|
| `calendar create` | `--transparency=free`, `--rrule` with `RRULE:` prefix |
| `api call … calendar.events.patch` | `--allow-write --force`, query `sendUpdates=none` |

## Why not `calendar respond`?

`gog calendar respond` only takes `--status` / `--comment` and does not expose `sendUpdates`. Declining through it may email the organizer. Always use `calendar.events.patch` with `sendUpdates=none` for declutter.

## Hiding declined events

Google Calendar UI: Settings → View options → uncheck **Show declined events** (default is often off). Declined series then leave the main grid while Aaron misc holds the Free archive.
