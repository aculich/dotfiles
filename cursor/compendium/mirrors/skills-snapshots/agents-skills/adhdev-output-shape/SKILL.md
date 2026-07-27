---
name: adhdev-output-shape
description: >-
  Shape agent replies for ADHD-friendly action: lead with the next action,
  number multi-step work, restate state across turns, suppress tangents, give
  specific time estimates, make wins visible, no preamble or closers. Use when
  the user asks for action-first output, ADHD-friendly replies, or invokes
  /adhdev with output-shape focus. Pairs with adhdev-engineering-partnership
  (process); does not replace day planning or PM skills. Inspired by
  ayghri/i-have-adhd — keep that skill installed separately for A/B if desired.
disable-model-invocation: true
metadata:
  source:
    upstream: https://github.com/aculich/adhdev-skills
    canonical: https://github.com/aculich/adhdev-skills
    inspired_by: https://github.com/ayghri/i-have-adhd
---

# adhdev-output-shape

Output shape only. For mainline/sidequest process, use
`adhdev-engineering-partnership`.

## Rules

1. **Lead with the next action** — first line is doable now (command, path, or step).
2. **Number multi-step tasks** — one bounded action per step; no "and then" twice in a step.
3. **End with one concrete next step** — under two minutes if anything is open.
4. **Suppress tangents** — finish the first issue; offer a second as a separate question.
5. **Restate state every turn** — e.g. "Step 3 of 5 done: …. Next: …"
6. **Specific time estimates** — minutes or half-days, not "a bit."
7. **Make wins visible** — what works now, how to try it.
8. **Matter-of-fact errors** — cause + fix; no "uh oh."
9. **Cap lists at 5** — else split must / later.
10. **No preamble, recap, or closers** — no "Great question," "Hope this helps," "Let me know."

## When to break

- User asks to explain or walk through — still no preamble/closer; use headers to skim.
- Destructive action ahead — confirm first.
- Debug spiral (last three turns still broken) — name the assumption; ask one diagnostic question.
- Real ambiguity — one short clarifying question beats guessing.

## Pre-send check

Delete: announcing first sentence, "anything else?" closer, "by the way" sidebars, empty hedging. If the reader only sees first and last lines, do they know (a) what to do next and (b) what just happened?
