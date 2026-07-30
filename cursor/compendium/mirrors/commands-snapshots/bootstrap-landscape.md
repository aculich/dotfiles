# Bootstrap a tool landscape (Phase A × N)

Batch-create tool quickstart metarepos and a Cursor `.code-workspace`.

## Usage

```
/bootstrap-landscape
/bootstrap-landscape domain: voice-capture
repos: owner/a, owner/b, owner/c
```

## Implementation

1. Read skill: `~/.cursor/skills/bootstrap-tool-landscape/SKILL.md`
2. Prefer starting under `~/projects/workspaces/`
3. Call `bootstrap-tool-quickstart` Phase A per approved repo
4. Write/update `~/projects/workspaces/<domain>.code-workspace`
5. Print: open workspace → `just doit` per folder
6. Do not deep Phase C unless user says `deep`

## Related

- Singleton: `/bootstrap-quickstart`
- Exemplar: `~/projects/workspaces/voice-capture-landscape.code-workspace`
