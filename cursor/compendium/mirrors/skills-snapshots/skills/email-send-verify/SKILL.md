---
name: email-send-verify
description: Empirically verify whether a drafted partner email was actually sent, by searching the appropriate org Gmail mailbox rather than assuming from a GitHub comment, issue, or doc draft. Use when a message exists as a draft/comment and someone asks "did it actually go out?", before analyzing reception, or before nudging a counterparty. Produces a send-verification note with an evidence table.
disable-model-invocation: true
---

# Email send verification (text activation check)

A text staged on GitHub / in a doc is **not** a sent email. In institutional-ethnography terms,
an email is only *activated* when it lands in a mailbox and starts coordinating action. Verify
activation empirically before analyzing reception or forecasting replies.

Part of a 3-skill suite (run in this order):
1. **email-send-verify** (this skill) — did the text activate?
2. `voice-contrast-analysis` — how did the final text differ from our draft?
3. `standpoint-scenario-forecast` — how will recipients receive it and reply?

## Workflow

1. **Identify the staged text** (GitHub comment, doc, issue body) and its timestamp. Quote the
   canonical URL.
2. **Pick the correct mailbox** for the workspace's org binding (check `.cursor/rules/` /
   `.workspace-tools.json`; never cross orgs). Use the `google-workspace` MCP
   `search_gmail_messages` with `user_google_email` set explicitly.
3. **Search wide to narrow**, recording every query and result count:
   - Topic keywords + `newer_than:3d`
   - Sender/recipient names + `newer_than:7d`
   - `in:anywhere (<keywords OR people>) newer_than:14d` (catches spam/trash/archives)
   - Longest-range topic-only query (e.g. `in:anywhere <topic> newer_than:30d`)
4. **Run a control query** (`in:anywhere newer_than:2d`, fetch headers) to prove the mailbox and
   search work — a zero result must be a true negative, not an auth failure.
5. **Write the verification note** using the template below.
6. If found: record From/To/CC/Date/Subject/Message-ID and **diff the sent body against the
   staged text** — flag scope, names, and commitments that changed.

## Output template

```markdown
# <Topic> email send verification

**Checked:** <date time TZ> · mailbox `<addr>`

## Verdict
SENT / NOT VERIFIED AS SENT — one-paragraph interpretation (not-yet-sent vs sent-without-CC),
with the staged-text URL and timestamp.

## Evidence table
| Query | Scope | Result |
|---|---|---|
(include the control query row)

## Headers
From/To/CC/Date/Subject/Message-ID — or "None available."

## Staged vs sent delta
Diff or "Not applicable until a sent message exists" + what to watch when re-checking.

## Re-check procedure
The single best query to re-run, and what to record.

## Follow-up flag
When absence starts to matter (deadline decay) and who to nudge.
```

## Worked example

`~/projects/cidr-san-mateo-21elements/notes/2026-08-12-costar-email-send-verify.md`
(CoStar #86: comment staged 10:32 PT, zero matches in 30d, control query healthy → verdict
"not verified as sent").
