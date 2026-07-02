# Communications — naming, metadata, and STATUS

Each tracked external thread (county, court, funder, advisor) gets a markdown summary file here so future readers — human or AI — can reconstruct the trail without re-reading every email.

## Naming

```
YYYY-MM-DD-NNN-short-description.md
```

- `YYYY-MM-DD` — the date of the **most recent** message you are filing.
- `NNN` — three-digit ordinal within that date (`001`, `002`, …) so multiple comms on the same day stay sortable.
- `short-description` — kebab-case, includes the **counterparty surname or org** + the **substantive ask** (e.g. `chris-sow-v3-sent-drive-bundle`, `lauren-records-form-index-followup`).

## File frontmatter

```yaml
---
comms_id: COMMS-YYYY-NNN
date: YYYY-MM-DD
direction: inbound | outbound | internal
parties:
  - name: First Last
    org: Organization
    email: x@y.org
    role: their role
status: awaiting-response | actioned | filed-only | needs-review
related:
  - decisions.md#DNN
  - next-actions.md row N
  - shared/manifests/<timestamp>.yaml
---
```

After the frontmatter:

- **TL;DR** (1–2 sentences)
- **Verbatim quote** of the substantive ask or commitment (so search hits the actual words)
- **What was decided / sent / asked**
- **Next action** (if any) — and add or update the matching row in `STATUS.md` and `.context/next-actions.md`
- **Privacy:** strip phone numbers, private scheduling URLs, and unrelated quoted threads. If a long quoted history is necessary, summarize it.

## STATUS.md

The dashboard. Required columns:

| Thread | Counterparty | Last touch | Status | Awaiting | File |

Keep it short — a single line per active thread plus a "recently closed" section at the bottom.

## Skills

- **`cidr-bootstrap-project`** seeds this folder.
- **`context-engineering`** updates `.context/decisions.md`, `next-actions.md`, and `outcomes.md` when a comm changes the project's posture.
- **`meeting-sync`** is for transcripts, not email — but cross-reference here when a meeting and a comm reference the same decision.
