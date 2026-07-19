# Publishing & marketplace readiness

Notes for maintainers preparing this skill for open distribution (Agent Skills / Cursor / Claude).  
**Status:** private repo today — do not publish until explicitly requested.

## Standards to follow

- [Agent Skills specification](https://agentskills.io/specification) — `name` matches directory; frontmatter required; progressive disclosure
- [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) — concise SKILL.md, gotchas, scripts for repeated logic
- [Cursor Skills docs](https://cursor.com/docs/skills) / community writeups on `~/.cursor/skills/` discovery
- Install via [vercel-labs/skills](https://github.com/vercel-labs/skills): `npx skills add <owner>/<repo>`

## Package checklist (pre-public)

- [x] `SKILL.md` with `name`, `description`, `license`, `compatibility`, `metadata.version`
- [x] `scripts/` + `templates/` (executable bootstrap)
- [x] `references/` for progressive disclosure (gotchas)
- [x] `LICENSE` (MIT)
- [x] `README.md` with install / invoke / non-goals
- [x] `CHANGELOG.md` (Keep a Changelog style)
- [ ] Eval scenarios under `evals/` exercised on a fresh machine
- [ ] Public description free of private paths (`~/tools/macosx-tools` → documented as default example only)
- [ ] Topics on GitHub: `agent-skills`, `cursor`, `claude-code` (when public)
- [ ] Optional: list on [skills.sh](https://skills.sh) / SkillsMP-style aggregators after public

## Local monorepo sync

Canonical authoring also lives in `aculich/agent-skills` under `skills/.curated/research-clone-bootstrap/`.  
Standalone repo is the **marketplace-shaped** unit; monorepo is the **install sync** unit for the author’s machines.
