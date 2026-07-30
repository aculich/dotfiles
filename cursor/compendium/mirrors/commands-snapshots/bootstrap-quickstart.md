# Bootstrap a tool quickstart metarepo (Phase A)

Create `~/tools/<slug>-metarepo/` with upstream pin, PHASES.md, and real `just doit`.

## Usage

```
/bootstrap-quickstart owner/repo
/bootstrap-quickstart yazinsai/OpenOats
```

## Implementation

1. Read skill: `~/.cursor/skills/bootstrap-tool-quickstart/SKILL.md`
2. Default path: `~/tools/<slug>-metarepo` (not `-quickstart`)
3. Ship PHASES.md + tool-quickstart.justfile from `~/.cursor/skills/dwim-justfile/templates/`
4. Phase A only; hand-off: open folder → `just doit` → `just phase C` / `just scaffold-lineages`
5. Phase D default triad: public + personal + team (`WITHOUT_TEAM=1` to skip team)

## Related

- Landscape: `/bootstrap-landscape`
- Justfile: `/dwim-justfile`
