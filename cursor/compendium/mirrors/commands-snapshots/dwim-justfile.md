# Create a DWIM justfile

Scaffold or enrich a repo-root justfile with `help`, `status`, `doctor`, and a real `doit`.

## Usage

```
/dwim-justfile
/dwim-justfile apply
/dwim-justfile --tool-quickstart
/create-justfile
/create-justfile apply
```

## Implementation

1. Read skill: `~/.cursor/skills/dwim-justfile/SKILL.md`
2. For `*-quickstart` / `upstream/` trees: use `templates/tool-quickstart.justfile`
3. Dry-run if justfile exists; write after `apply`
4. Never ship “fill in happy path” as the only `doit` body
5. Verify: `just` and `just doctor`

## Related

- Full envelope: `/bootstrap-quickstart`
- Alias: `/create-justfile` → same skill
