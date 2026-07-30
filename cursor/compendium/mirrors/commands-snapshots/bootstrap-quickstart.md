# Bootstrap a tool quickstart metarepo (Phase A)

Create `~/tools/<slug>-quickstart/` (or in-place / `*-metarepo` if asked) with upstream pin and real `just doit`.

## Usage

```
/bootstrap-quickstart owner/repo
/bootstrap-quickstart Beingpax/VoiceInk
/bootstrap-quickstart owner/repo https://example.com/product
```

## Implementation

1. Read skill: `~/.cursor/skills/bootstrap-tool-quickstart/SKILL.md`
2. Follow Phase A checklist only (no dossier/PRD/PLAYBOOK)
3. Install justfile from `~/.cursor/skills/dwim-justfile/templates/tool-quickstart.justfile`
4. Commit Phase A; print: open folder → `just doit`
5. Do not open Cursor mid-A; inception UX in exemplar `INCEPTION.md`

## Related

- Landscape: `/bootstrap-landscape`
- Justfile only: `/dwim-justfile`
- Alias skill names: `tools-quickstart-bootstrap`, `bootstrap-product-quickstart`
