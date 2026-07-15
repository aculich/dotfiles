---
name: collab-sync
description: >-
  Collab dashboard: check for peer bottle/ack responses, companion repo,
  git state, and Granola index gaps. Use when user says check for responses,
  sync, refresh, any bottles, or did Ethan ack. Read-only by default; mutate
  only on sync apply.
disable-model-invocation: true
---

# Collab sync (dashboard)

Look for **responses** and refresh collab state. Cursor is the living command center; `just check` / `just agent-check` are the CLI twins.

## When to use

- “Any word from Ethan?” / “check for responses” / “did they ack?”
- “sync” / “refresh” / “dashboard”
- After OOB SMS/email hinting a bottle was pushed

## Modes

| Mode | Trigger | Writes? |
|------|---------|---------|
| **Check** (default) | `/collab-sync`, `just check`, `just agent-check`, or plain “check” | No — report only |
| **Sync apply** | user says `sync apply` / `go ahead` / `apply` after a check, or `just agent-sync` with apply intent | Yes — bottle receive, conventions, workspace (gated) |

## Checklist

```
- [ ] Read .context/conventions.md (entanglement_status, companion_repo_https, peer_github, peer_repo)
- [ ] Bottles: list outbox / inbox / ack; flag unanswered ping
- [ ] Companion probe: gh api known URL, else repos/<peer_github>/<peer_repo>
- [ ] If companion exists: fetch/list peer bottles/outbox for new files
- [ ] Git: status -sb; ahead/behind origin
- [ ] Granola: index.json ids vs MCP list_meetings (folder EZW) — report only
- [ ] Emit dashboard block (below)
- [ ] If ack/companion_repo found and mode is sync apply → message-in-a-bottle receive + workspace update
```

Prefer running `just check` (or `scripts/collab-check.sh`) for the deterministic shell half, then enrich with MCP.

## Dashboard output (required shape)

```markdown
### Collab dashboard
- entanglement: <status> | companion: <url or pending>
- bottles: outbox=N inbox=N ack=N | unanswered_ping: yes/no
- peer repo: <full_name | 404 | error>
- peer outbox new: <filenames or none>
- git: <status -sb one-liner>
- granola mirrored: N | MCP new ids: <list or none>
- next: <one concrete action for the human>
```

## Sync apply (gated)

Only when explicitly authorized:

1. Follow **`message-in-a-bottle`** receive checklist (copy to `bottles/inbox/`, write `bottles/ack/`).
2. Update `companion_repo_https`, `entanglement_status: entangled` in conventions.
3. Update `~/projects/workspaces/from-atoz.code-workspace` second folder if needed.
4. Do **not** auto-ingest Granola — point human at **`discover-channel`** / paste URL.

## Pair with

- `message-in-a-bottle` — receive/ack protocol
- `discover-channel` — paste a new Granola/Zoom/Tana URL
- `bootstrap-collaborator` — entanglement complete after ack

## Out of scope

- Autonomous polling / cron
- Auto-ingest every new Granola meeting
- Pedestrian commit messages (whimsy required in AGENTS.md)

## See also

- [reference.md](reference.md) — just recipes, cursor-agent prompts, shell probe
- `docs/AUTOMATION.md`
