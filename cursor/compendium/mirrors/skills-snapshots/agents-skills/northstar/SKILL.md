---
name: northstar
description: >-
  Anchors any task in purpose, objective, and desired outcomes grounded in real
  codebase/context before choosing tools or skills. Enforces tool-first
  (brew/uv/bun/cargo/gh) and only uses or creates a skill when a deterministic
  tool is unsuitable or needs augmentation. Use when the user invokes /northstar,
  asks to clarify purpose/objectives/outcomes, or wants to evaluate tool-vs-skill
  options before proceeding.
disable-model-invocation: true
metadata:
  internal: true
version: 0.1.0
---

# Northstar

Get really clear on the purpose, objective, and desired outcomes as an anchor and north star so we're grounded in the reality of the codebase or other context and what the desired outcome is.

Prefer thoughtful, well-established, purpose-built deterministic tools (`brew` / `uv` / `bun` / `cargo` / `gh` / etc.) that save tokens. Only use or create a skill when a tool isn't suited, or needs augmentation — not wholesale replacement.

Research background: `research/northstar-tool-first/` in the agent-skills monorepo.

## Phase 0 — North star block

Write this block from **observed** context (run `git remote -v`, `git status -sb`, read project docs as needed). Mark unknowns explicitly.

```markdown
## North star

**Purpose:**
**Objective:**
**Desired outcomes:**
**Grounding facts:**
**Non-goals:**
```

**Completion criterion:** All five fields filled; desired outcomes are checkable; grounding cites real paths/remotes/constraints.

Show the block to the user before Phase 1 if anything is ambiguous.

## Phase 1 — Tool-first gate

1. List mechanical work implied by the objective (sync, changelog, lint, fetch, test, …).
2. For each item, name an installable deterministic tool if one exists.
3. Prefer tools already on PATH; otherwise note `brew`/`uv`/… install commands.
4. **If tools cover the purpose:** skip to Phase 3 with decision `tools-only`.

**Completion criterion:** Explicit yes/no — “Do tools fully cover desired outcomes?”

## Phase 2 — Skill gap (only if tools leave a gap)

1. State the gap in one sentence (judgment, policy, multi-step orchestration).
2. If comparing multiple candidate skills, invoke **`evaluate-skills`** (or follow its skeleton) with this north star block + candidate list.
3. Otherwise: find one skill, or invent a **thin** experimental skill that wraps tools and encodes only the missing judgment.

**Completion criterion:** Decision recorded: `select` | `hybrid` | `invent` | `tools-only`.

## Phase 3 — Proceed and report

Execute the chosen stack. Report against **Desired outcomes** (met / not met / blocked).

**Completion criterion:** Every desired outcome has a status line.

## Examples

See [examples.md](examples.md).

## Gotchas

- Do not invent grounding facts — inspect the tree.
- Do not install community skills during Phase 0–1 “just in case.”
- User-invoked (`/northstar`): do not rely on ambient auto-trigger.
