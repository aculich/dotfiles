# Bootstrap AAR — reference

## Filename

`dossier/AAR-YYYY-MM-DD-<role>.md`

Examples: `AAR-2026-07-30-sidequest.md`, `AAR-2026-07-30-workhorse.md`.

## Section skeleton

```markdown
# After Action Report — <tool> metarepo <role> regen

| Field | Value |
|-------|-------|
| Date | |
| Laptop role | SideQuest / WorkHorse |
| Branch tip | |
| Primary PR | |
| Handoff issue | |

## 1. Expected at the outset
## 2. What we see in the repo
## 3. Session narrative
## 4. What we discovered
## 5. What we fixed / generated
## 6. Key outputs and outcomes
## 7. Commands for the peer laptop / reviewer
## 8. Chat-history index
```

## Canonical VoiceInk example

See [dossier/AAR-2026-07-30-sidequest.md](../../../dossier/AAR-2026-07-30-sidequest.md).

## Discussion body tips

- Lead with 5–10 line executive summary
- Link AAR blob URL, PR, issue, SIDEQUEST Lessons
- Q&A thread: symptom → root cause → fix commands only
- Ideas thread: explicit ask list for WorkHorse/SideQuest peer

## GraphQL category slugs (defaults after enable)

| Slug | Use |
|------|-----|
| `show-and-tell` | AAR showcase |
| `q-a` | Failure-mode FAQ |
| `ideas` | Merge / process proposals |
| `general` | Catch-all if needed |
