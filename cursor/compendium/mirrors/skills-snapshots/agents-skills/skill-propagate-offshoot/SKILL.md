---
name: skill-propagate-offshoot
description: >-
  Propagates a prototype-born agent skill or Cursor slash command out of a
  product/tools birth site into its own pack (or agent-skills curated),
  generalizing product-specific strings, leaving a pointer capsule at the birth
  site. Use when the user runs /skill-propagate, asks to root an offshoot,
  mature a cutting, extract a skill pack from a product repo, or when
  chaos-containment extract finds a skills/commands tree.
disable-model-invocation: true
metadata:
  internal: true
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
  pairs-with:
    - skill: chaos-containment
      reason: Generic extract defers here for skill/command trees
---

# skill-propagate-offshoot

Take a cutting from a birth site, root it in its own pot. The shoot grows
independently and carries parent genetics. Leave a capsule at the stump—never
a dig site.

This is **propagation**, not grafting. Grafting (attach foreign capability onto
a living host without freestanding product) is a sibling operation—reserve
`skill-graft-into-host` for later; do not fold it into this skill.

## Invocation

```text
/skill-propagate <birth-path>
/skill-propagate <birth-path> --pack ~/projects/<name>
/skill-propagate <birth-path> --into-agent-skills
```

Default is **dry-run**. Apply only after confirm (`propagate apply`, `go ahead`,
or same-message `apply`).

Companion slash: install `assets/cursor-command.md` → `~/.cursor/commands/skill-propagate.md`.

## Workflow

Copy this checklist:

```text
Propagate offshoot:
- [ ] Inventory birth artifacts
- [ ] Classify protocol vs instance vars vs product-only vs hitchhikers
- [ ] Propose destination (pack vs agent-skills/.experimental)
- [ ] Dry-run report ([plan] lines) — wait for apply
- [ ] Generalize + write destination
- [ ] Install globally + slash command if any
- [ ] Capsule at birth site + provenance
- [ ] Log in docs/OFFSHOOTS.md when present
```

### 1. Inventory

Collect: `SKILL.md` tree(s), slash commands, instance docs (`ADHDEV.md`-style),
product-specific strings/paths, licenses, ATTRIBUTION.

### 2. Classify

| Class | Action |
|-------|--------|
| Protocol / reusable guidance | Goes into the cutting (generalized) |
| Instance variables | Stay at birth site (template + local fill) |
| Product-only lore | Leave behind |
| Hitchhikers (manifesto essays, unrelated skills) | **Forbid** in the pack—park elsewhere (e.g. code-sculpting) |

### 3. Destination

- **`~/projects/<pack>`** — preferred for installable packs (`npx skills add`); slim bootstrap (README, justfile, docs/AUTOMATION.md, `.context/intent.md`, `skills/`, `templates/`).
- **`agent-skills/skills/.experimental/`** — when the shoot is mgmt/meta and belongs in the monorepo first.

Do **not** nest freestanding packs inside `agent-skills/` as sub-repos.

### 4. Generalize

Strip product names and hard-coded birth paths. Parameterize via templates.
Update `metadata.source` to the new pack or monorepo canonical URL.

### 5. Install

```bash
npx skills add <pack-or-monorepo-path> -g -a cursor -a claude-code -a codex -y
# or from agent-skills: just sync
```

Install slash command from pack/skill `assets/cursor-command.md` when present.

### 6. Capsule at birth

Leave a thin pointer skill or README stub: install URL, “read local instance
doc for variables,” steward one-liner. Do not delete birth instance docs—trim
them to instance-only.

## Related metaphors (short)

| Verb | Meaning |
|------|---------|
| Propagate | Own pot (this skill) |
| Graft | Onto host rootstock (sibling future skill) |
| Contain | Capsule / briefing (`chaos-containment`) |

Full crosswalk: `~/projects/code-sculpting/ideas/botanical-operations-crosswalk.md`.

## See also

- `chaos-containment` — defer skill/command trees here from `extract`
- `bootstrap-new-project` — slim greenfield for pack destinations
- Prototype-instance framing: storytelling-capsules AGENTS; proposal-studio praxis loop
- Code sculpting manifesto — progressive refinement; do not under-engineer forever
