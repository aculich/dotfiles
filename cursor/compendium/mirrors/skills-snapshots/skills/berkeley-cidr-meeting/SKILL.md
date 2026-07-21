---
name: berkeley-cidr-meeting
description: Dual-hat bCal→cCal shadow — copy a Berkeley calendar event onto aaron@cidrlab.org titled "Zoom for " + bCal title, with a CiDR Zoom link (no passcode), put bCal participants in the description only, invite only aculich@berkeley.edu, and draft (do not send) a bMail alt-Zoom note to the bCal organizer. Use when the user asks for berkeley-cidr-meeting, bCal→cCal, cCal shadow, alt-Zoom for a Berkeley invite, or dual-hat Zoom/calendar routing for cidrlab.
---

# berkeley-cidr-meeting (dual-hat shadow)

Canonical source: `~/tools/google-workspace-tools/.cursor/skills/berkeley-cidr-meeting/`  
Global install: `just berkeley-cidr-meeting-install` → symlink under `~/.cursor/skills/`

## Identities (never mix credentials)

| Step | Email | Tool |
|------|-------|------|
| Read bCal source | `aculich@berkeley.edu` | `user-google-workspace` `get_events` / `get_event` |
| Create CiDR Zoom | `aaron@cidrlab.org` (Zoom user) | `user-zoom` `create_meeting` |
| Create cCal shadow | `aaron@cidrlab.org` | Prefer `gog-as cidrlab calendar create` (MCP `create_event` has misrouted cidrlab→berkeley). Attendees **only** `aculich@berkeley.edu` |
| Draft alt-Zoom email | `aculich@berkeley.edu` | `draft_gmail_message` — **do not send** |

Hard rule: CiDR Zoom for the shadow/alt link — never paste UCB Zoom into CiDR delivery. This skill is the inverse (CiDR Zoom as alt for a Berkeley-owned invite).

## Zoom MCP routing

| Need | Server | Notes |
|------|--------|-------|
| **Create / update / delete meeting** | `user-zoom` (custom S2S) | Only path for `create_meeting` |
| Hub docs, assets, search, recordings list | `user-zoom-official` | Not for CRUD |
| Official OAuth env empty | Run setup script | See below |

Canonical Official MCP runbook: `~/projects/zoom-deeplistening-agents/ZOOM-OFFICIAL-MCP.md`  
Creds: `op://cidrlab/Cursor Zoom MCP` (mirror in `develop`). Setup:

```bash
OP_ACCOUNT=my.1password.com ~/projects/zoom-deeplistening-agents/scripts/setup-cursor-zoom-official-mcp.sh
# Then ask human: Cmd+Q Cursor → Connect zoom-official
```

**Preflight before create:** `get_account_profile` must show CiDR Lab / `aaron@cidrlab.org`. Wrong tenant → stop and ask. No workarounds.

## Checklist

Copy and track:

```
Task Progress:
- [ ] 1. Resolve bCal event (title or id) as aculich@berkeley.edu
- [ ] 2. Confirm Zoom S2S account is CiDR Lab
- [ ] 3. create_meeting on aaron@cidrlab.org (settings below)
- [ ] 4. Verify join URL has no passcode
- [ ] 5. create_event on aaron@cidrlab.org (shadow contract)
- [ ] 6. draft_gmail_message on aculich@berkeley.edu (do not send)
- [ ] 7. Report Zoom URL, cCal link, draft id
```

### 1. Resolve bCal

Prefer MCP `get_event` / `get_events`. Fallback: `gog-as berkeley calendar events list … --json` only if MCP auth fails and the user confirms.

Capture: `id`, `htmlLink`, `iCalUID`, `summary`, start/end, `organizer`, full `attendees`, `recurringEventId` if any, existing `location`.

### 2–4. Create CiDR Zoom

`user-zoom` `create_meeting`:

- `user_id`: `aaron@cidrlab.org`
- `topic`: bCal `summary`
- `type`: `2` (scheduled)
- `start_time` / `duration` / `timezone` from bCal
- **No password** — omit `password`; if response includes a non-empty passcode, stop and ask
- `settings`: see [reference.md](reference.md) (passcode off; waiting room follow portal intent; mute on entry; join anytime; cloud record; video on)

### 5. cCal shadow

Prefer CLI (verified on cidrlab):

```bash
gog-as cidrlab calendar create primary \
  --summary 'Zoom for <BCAL-TITLE>' \
  --from '<START>' --to '<END>' --timezone America/Los_Angeles \
  --location '<JOIN_URL>' \
  --description '<DESC>' \
  --attendees 'aculich@berkeley.edu' \
  --json --results-only
```

Confirm `htmlLink` / `organizer` contain `aaron@cidrlab.org` (not `berkeley.edu`).

- **cCal title:** verbatim prefix `"Zoom for "` (trailing space included) + bCal `summary`  
  Example: bCal `Weekly Research Sync` → cCal `Zoom for Weekly Research Sync`
- Same timeslot as bCal
- `location`: CiDR Zoom join URL
- `attendees`: **only** `aculich@berkeley.edu`
- `description`: template in [reference.md](reference.md) — Zoom URL, bCal htmlLink, participant emails (description only), plain + JSON metadata

In the `gog-as cidrlab calendar create` command above, `--summary` must be `"Zoom for " + bCal summary` (not the bare bCal title).

### 6. bMail draft

`draft_gmail_message` as `aculich@berkeley.edu`:

- `to`: bCal organizer email
- `subject`: `alt-Zoom link for <MEETING-TITLE>`
- Body: ask them to use the CiDR Zoom link on their invite; include join URL
- **Do not send**

## Failure policy

- Auth / fingerprint / OAuth: open browser or ask the human; wait. Do not invent tokens or fall back to the wrong vault/tenant.
- Wrong Zoom account, forced passcode, or missing scopes: report and ask how to resolve.

## CLI / cursor-agent

**Preferred headless path:** `zoom-for` (attach-aware) in this repo:

```bash
source ~/tools/google-workspace-tools/scripts/google-workspace-cli-aliases.zsh
zoom-for "Meeting title substr"          # next match
zoom-for --project rrid --today          # all RRID|RR\ID matches today (bCal + RR\ID Dev)
just zoom-for --project rrid --today --dry-run
```

Creates CiDR Zoom + cCal `"Zoom for "` shadow. Optional `--patch-source` rewrites that
source instance’s location; `--draft-mail` drafts (does not send) organizer mail.

Prefer in-Cursor MCP for interactive skill runs. Alternate headless:

```bash
cursor-agent -p --approve-mcps --force "Run berkeley-cidr-meeting for '<title or event id>'"
```

## Extension point

Default create target is **cidrlab** Zoom. Other orgs need their own S2S credentials + MCP route before agents schedule on those tenants.
