---
name: bootstrap-tool-landscape
description: >-
  Thin orchestrator: Phase A × N tool quickstarts + write/update a Cursor
  .code-workspace under ~/projects/workspaces/. Use with /bootstrap-landscape.
  Calls bootstrap-tool-quickstart per tool; does not deep Phase C unless deep.
disable-model-invocation: true
---

# Bootstrap Tool Landscape

Thin batch orchestrator over **`bootstrap-tool-quickstart`**. Exemplar workspace: `~/projects/workspaces/voice-capture-landscape.code-workspace`.

## Inception UX

1. Prefer starting from `~/projects/workspaces/`.
2. Phase A × N on disk — do not open Cursor mid-batch.
3. After batch: open the **`.code-workspace`** file; per folder run **`just doit`**.
4. Phase C per tool when ready; Phase E SuperPRD when rolling up.

## Inputs

| Input | Required | Notes |
|-------|----------|-------|
| Repo list | yes | `owner/repo` lines or comma-separated |
| Domain label | yes-ish | e.g. `voice-capture` → workspace filename |
| Peer discovery | no | Propose Tier 1/2 extras; **ask approval** before cloning |
| `deep` | no | If set, may start Phase C per tool (default: A only) |

## Checklist

```markdown
Landscape Progress:
- [ ] 1. Parse repos + domain; normalize slugs
- [ ] 2. Dedupe; gh api verify canonical upstreams
- [ ] 3. Optional: propose Tier 1/2 peers — wait for approval
- [ ] 4. For each approved tool: invoke bootstrap-tool-quickstart Phase A
- [ ] 5. Isolate failures (one tool fail ≠ abort batch)
- [ ] 6. Write/update ~/projects/workspaces/<domain>.code-workspace
- [ ] 7. Print hand-off: open workspace → just doit each → Phase C when ready → Phase E SuperPRD later
```

## Workspace file shape

```json
{
  "folders": [
    { "name": "hub-or-tool", "path": "/Users/me/tools/<slug>-quickstart" }
  ],
  "settings": {}
}
```

Use absolute paths. Prefer existing hub naming if user names a hub (e.g. willowvoice).

## Do not

- Deep-write every LANDSCAPE/PRD inside the landscape slash unless `deep`.
- Merge git histories into a monorepo.
- Re-bootstrap tools that already have a healthy `*-quickstart` unless user says overwrite/refresh.

## Related

- Factory: `bootstrap-tool-quickstart`
- Docs: exemplar `CONSTELLATION.md` / `INCEPTION.md` in voiceink-quickstart
