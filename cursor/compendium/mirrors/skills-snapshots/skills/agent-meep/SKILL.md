---
name: agent-meep
description: >-
  Agent mise en place (meep): Plan-mode preflight that provisions credentials,
  search boundaries, and escalation rules before Agent mode. Use when starting
  a long agent run, switching Plan→Agent, missing API keys/env vars, auth
  failure, sibling .env forage risk, throwaway prototypes without guardrails,
  or when the user says meep, mise en place, or seal the agent.
disable-model-invocation: true
---

# Agent mise en place (meep)

Run this in **Plan mode** (or before any long goal-oriented Agent run). Do not flip to Agent mode until the checklist passes or the human explicitly accepts residual risk.

**Core rule:** Caps ≠ isolation. Missing credentials → stop and ask. Never forage sibling projects or `$HOME` for `.env` / API keys.

## When to run

- User invokes `/agent-meep` or says meep / mise en place / seal the agent
- About to leave Plan mode for a job that needs network + provider keys
- Prototype / throwaway workspace with no documented inject path
- Auth failure or missing `*_API_KEY` mid-planning

## Workflow

Copy and fill:

```text
Agent meep:
- [ ] Job needs secrets? (list env vars / broker aliases)
- [ ] Inject path for THIS workspace (op run / Environment / Infisical / proxy / no-network)
- [ ] Key scope matches job (device/project — not sibling leftover)
- [ ] Spend posture OK (cheap prototype key or no-network)
- [ ] Search roots = workspace + documented inject only
- [ ] Escalation text present (AGENTS.md / rules) or stated in meep report
- [ ] Smoke: inject works OR human waived with explicit risk accept
→ READY for Agent mode / NOT READY (blockers below)
```

### 1. Name what the job needs

List required secrets by **name only** (e.g. `OPENAI_API_KEY`). Read `.env.example` / README for names — not live values from foreign trees.

If the job needs **no** provider calls: mark inject path `no-network` and skip credential smoke.

### 2. Confirm inject path (this workspace only)

Prefer, in order:

1. Documented project inject (`op run`, 1Password Environment, Infisical)
2. Sandbox / credential proxy (agent never sees the value)
3. Explicit human paste **for this session only**
4. Explicit **no-network** until keys exist

For 1Password CLI reads/inject, follow the `op-credentials` skill. On `op` auth failure: report and wait — no sibling-`.env` workaround.

### 3. Bound discovery

| May | Must not |
|-----|----------|
| Workspace docs, `.env.example`, named inject helpers | Sibling repos, `$HOME` secret dirs, other projects' `.env` |
| Ask human to provision / authorize | Borrow keys “temporarily” into `/tmp` |
| Stop on 401 / missing var | “Any key that works” scavenger hunt |

### 4. Escalation (must be loaded before Agent mode)

Ensure project `AGENTS.md` / rules include the paste block in [reference.md](reference.md), or paste the block into the meep report so Agent mode inherits it for this session.

### 5. Emit a meep report

End Plan-mode meep with:

```markdown
## Meep report

**Verdict:** READY | NOT READY

| Item | Status |
|------|--------|
| Required secrets | … |
| Inject path | … |
| Scope | … |
| Spend posture | … |
| Search roots | workspace-only (+ …) |
| Escalation loaded | yes/no |

**Blockers:** …
**Human asks:** …
**Do not:** forage sibling `.env`; spend foreign keys; continue Agent mode if NOT READY unless human overrides.
```

Only recommend Agent mode when verdict is READY, or the human explicitly overrides in chat.

## Anti-patterns

- Using another local project's `.env` to unblock the task
- Treating billing caps on other projects as authorization
- Pasting live secrets into chat or committing them
- Skipping meep because “it's just a prototype”

## Additional resources

- Paste block + normative rules: [reference.md](reference.md)
- Landscape analysis (optional read): `~/projects/secrets-management/inquiry/analysis/2026-07-29-agent-borrowed-sibling-api-key.md`
- Desktop key standard: `~/projects/secrets-management/inquiry/standards/desktop-api-keys.md`
