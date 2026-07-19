# peeq-cidr-meeting reference

## From preference (mail)

| Recipient class | Prefer `--from` |
|-----------------|-----------------|
| ca.gov / enterprise / unknown filters | `aaron@peeq-work.com` |
| Friendly / already know peeq.work | `aaron@peeq.work` (optional) |

Both aliases land in the asemicarche inbox. Calendar layer stays **pCal** (PEEQ secondary); organizer is never a peeq address with aliases alone. See [docs/aallc-multi-domain-identity.md](../../../docs/aallc-multi-domain-identity.md) architecture ladder + `.work` playbook.

## Zoom settings

Same payload as berkeley-cidr-meeting (CiDR Lab, no passcode). Shared preferred defaults: [docs/cidrlab-setup.md — Zoom (CiDR Lab)](../../../docs/cidrlab-setup.md#zoom-cidr-lab).

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

Omit `password`. Confirm no `pwd=` in `join_url`.

## PEEQ calendar

- Id: `c_6432308bf58d6714d4091f7771e1aac2dc43a4f66b13d68edfd2196cadf37a5f@group.calendar.google.com`
- Title prefix: `"Zoom for "` (verbatim, trailing space) + title
- Dry-run invitee: only `aculich@berkeley.edu`

## Description template

```
CiDR Zoom (alt link for this peeq shadow invite):
<JOIN_URL>

Intended From (mail): aaron@peeq-work.com   # gov/enterprise default; or aaron@peeq.work
Calendar layer: PEEQ (AALLC secondary; creator aaron@asemicarche.com)

Intended guests (listed here only — not invited on dry-run):
- <email1>
…

Dry-run invitee: aculich@berkeley.edu

--- plain metadata ---
cCal_title: Zoom for <TITLE>
…
```

## Draft template

```
To: aculich@berkeley.edu
From: aaron@peeq-work.com   # prefer for gov; optional aaron@peeq.work for friendly
Subject: alt-Zoom link for <TITLE>

Hi,

Please use this as the Zoom link for "<TITLE>":

<JOIN_URL>

This is a CiDR Lab Zoom link (no passcode). Draft for peeq+cidr dry-run — do not send to Miroo yet.

Thanks,
Aaron
```

## Miroo addresses (harvest 2026-07-16)

| Email | Where seen |
|-------|------------|
| `miroo@peopleculture.co` | aallc + personal (CARB / People Culture) |
| `mirook@gmail.com` | personal (SIY Bay Area Fusion Pod) |

Do not contact until Aaron asks.

## Dry-run (2026-07-16) — `PEEQ <> Miroo`

| Artifact | Value |
|----------|-------|
| Zoom | https://zoom.us/j/98198055763 (id `98198055763`, no passcode) |
| PEEQ event | `tqjivu75o9pqh5a3ch0tgglvf0` — title `Zoom for PEEQ <> Miroo` |
| Organizer | PEEQ group cal; creator `aaron@asemicarche.com` |
| Invitee | only `aculich@berkeley.edu` |
| Draft | `r-8129259071980996375` / msg `19f6d5ed852dd826` — intended From peeq; actual From primary (send-as **pending** verification) |

## Real invite (2026-07-16) — `PEEQ <> Miroo — module 2`

| Artifact | Value |
|----------|-------|
| Slot | **2026-07-22 15:30–16:30 PT** (first free ≥60m after 13:00; existing bCal block 14:00–15:30) |
| Zoom | https://zoom.us/j/95538620986 (id `95538620986`, no passcode) |
| pCal event | `sjbmkbe2sb94i17rk7sikb42as` — `Zoom for PEEQ <> Miroo — module 2` |
| Attendees | `miroo@peopleculture.co`, `aaron@asemicarche.com` |
| Draft (unsent) | `r-3764817199873973856` From `aaron@peeq.work` — **ask before send** |
| Send-as | `aaron@peeq.work` **accepted** after DWD settings + confirm link |

## TEST berkeley probe (2026-07-16)

| Artifact | Value |
|----------|-------|
| Zoom | https://zoom.us/j/95090131875 |
| pCal | `otnheb7g98o4l2vju1ci6v3dqc` — `TEST: Zoom for peeq-cidr berkeley probe` Jul 21 15:00 PT |
| Draft | `r4451014801680950649` From peeq — unsent |

## Dry-run (2026-07-16) — peeq-work.com From preference

| Artifact | Value |
|----------|-------|
| Zoom | https://zoom.us/j/96052563396 (id `96052563396`, no passcode) |
| pCal event | `aek7dk4dbqal3tvsqvnajpbrtk` — `Zoom for TEST: peeq-work.com From dry-run` Jul 17 16:00–16:30 PT |
| Organizer | PEEQ group cal; creator `aaron@asemicarche.com` |
| Invitee | only `aculich@berkeley.edu` |
| Send-as | Created `aaron@peeq-work.com` — **accepted** immediately (user-alias domain) |
| Draft (unsent) | `r3009747015534183069` / msg `19f6d84b4f9bec75` — **From `aaron@peeq-work.com`** |

## Pointers

- [docs/aallc-multi-domain-identity.md](../../../docs/aallc-multi-domain-identity.md)
- Zoom Official MCP: `~/projects/zoom-deeplistening-agents/ZOOM-OFFICIAL-MCP.md`
- Sibling skill: `berkeley-cidr-meeting`
