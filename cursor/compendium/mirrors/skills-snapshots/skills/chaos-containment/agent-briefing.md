# Agent briefing template

> Never drop data without its context and intent — leave a capsule, not a dig site.

**Required** on every PDV drop (`quick-stash` / `tidy-stash` / chaos-containment → PDV).  
Incomplete briefing = incomplete move.

Place `AGENT-BRIEFING.md` next to the dropped batch (or one per subfolder if purposes differ).

Copy and fill:

```markdown
# Agent briefing — <short title>

> Never drop data without its context and intent — leave a capsule, not a dig site.

## Capsule summary
- **What:** …
- **Whence:** <absolute path or repo>
- **When:** YYYY-MM-DD (UTC)
- **Purpose:** <user-stated or inferred; label inference>
- **Sensitivity:** public | internal | SENSITIVE/PII
- **Moved by:** chaos-containment / quick-stash / tidy-stash

## Inventory
| Path | Notes |
|------|-------|
| | |

## Intent for the receiving agent
What a PDV / data-service agent should do next (or *not* do). Prefer concrete next steps over “figure it out.”

## Anticipated Q&A
- **Q:** Who owns this? **A:** …
- **Q:** May it leave the vault / be summarized or indexed? **A:** …
- **Q:** Related project or lab? **A:** …
(Add more obvious questions a busy multi-context operator would otherwise get interrupted for.)

## Do not
- Push to public remotes
- …

## Links
- Skill: chaos-containment, quick-stash
- Ethos: ~/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md
```

## Non-PDV equivalents

| Destination | Artifact |
|-------------|----------|
| Google Drive | Local `OFFLOAD.md` (same fields + Drive path/URL); one-liner at top |
| git-lfs / DVC | Short pointer README beside pointers; one-liner at top |

## Quality bar

Before finishing, ensure a stranger agent could answer ownership, sensitivity, next action, and hard stops **without** asking the human for basics you already knew at drop time.
