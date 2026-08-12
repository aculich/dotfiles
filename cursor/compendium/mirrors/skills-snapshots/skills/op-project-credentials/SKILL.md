---
name: op-project-credentials
description: Bootstrap a 1Password project credentials hub in personal-ops, wire .env.op + CREDENTIALS.md, and create/mount a 1Password Environment as project .env. Use when setting up project environment credentials, Project - {name} op items, Environments mounts, migrating shared keys, or rotating project-owned API keys.
---

# 1Password project credentials hub

Complements [`op-credentials`](../op-credentials/SKILL.md) (day-to-day `op read` / `op run`) and the Cursor **1password-environments** skill (Environments MCP).

This skill creates **both**:

1. One vault hub item — `personal-ops` / `Project - {slug}`
2. One 1Password Environment — same slug — mounted at `{repo}/.env`

## When to use

- User asks for project credentials / environment setup in 1Password
- Bootstrap keys from `develop` or WorkHorse into one manageable record
- Wire `.env.op`, `CREDENTIALS.md`, and a mounted `.env`
- Rotate from shared/generic keys to project-owned keys later

## Hard rules

- Always `OP_ACCOUNT=my.1password.com`
- On `op` auth failure: stop, report, wait — no plaintext workarounds
- Never print secret values in chat or commit plaintext secrets
- Prefer template/stdin for vault creates; delete temp files after use
- **Never `Read` / `cat` a mounted `.env`** — it is a FIFO; use `list_variables` for names
- Scrub any temp JSON that held secret values before ending the turn

## Vault roles

| Vault | Use for |
|-------|---------|
| **`personal-ops`** | **Default hub** for `Project - {slug}` items |
| `develop` | Legacy shared generics — bootstrap source only |
| `workhorse` / `sidequest` | Device gateway secrets — not the project hub |

## Dual delivery (both required)

| Artifact | Purpose |
|----------|---------|
| Vault item `Project - {slug}` | Source of truth + provenance notes + `op://` refs |
| `.env.op` | Commit-safe refs for `op run --env-file .env.op` |
| Environment `{slug}` + mounted `.env` | Apps/tools that load dotenv from `.env` automatically |
| `CREDENTIALS.md` | Human docs (names, provenance, usage — no secrets) |

Do not treat the Environment as a replacement for the hub item. Keep both in sync when rotating.

## Item model (vault hub)

| Property | Value |
|----------|-------|
| Category | `API Credential` |
| Title | `Project - {slug}` — **ASCII hyphen only** |
| `username` | project slug |
| `credential` | primary secret |
| Custom fields | one **CONCEALED** field per env var |
| `primary_env` / `bootstrap_status` | metadata |
| Tags | `project`, `{slug}`, `bootstrap`, `pending-rotation`, optional `WorkHorse` |

### Title / ref pitfalls

- No middle-dot `·` in titles used inside `op://` refs.
- WorkHorse items often use `·` — read by **full UUID** (26 chars), never a truncated id.
- Environment **name** should match `{slug}` (same as hub slug; no `Project -` prefix).

## Workflow checklist

```
- [ ] Confirm slug + required env var names
- [ ] Auth: op whoami + Environments MCP authenticate
- [ ] Check personal-ops for existing Project - {slug}
- [ ] Resolve bootstrap sources (WorkHorse UUID → develop fallback)
- [ ] Create/update vault hub + provenance notes
- [ ] Write .env.op + CREDENTIALS.md; ensure .env is gitignored (not git-tracked)
- [ ] Verify op run --env-file .env.op (lengths only)
- [ ] list_environments — create Environment {slug} if absent
- [ ] append_variables (concealed: true for secrets)
- [ ] create_local_env_file mountPath={repo}/.env
- [ ] list_local_env_files + list_variables verify
- [ ] Scrub temp secret files
```

### 1. Discover + create vault hub

Same as before: list vaults, bootstrap by UUID priority, create `API Credential` via template, write `.env.op` / `CREDENTIALS.md`. Details: [reference.md](reference.md).

### 2. Create + mount Environment (mandatory unless user opts out)

Follow **1password-environments** for MCP details. Summary:

1. `authenticate` → `accountId`
2. `list_environments` — if `{slug}` exists, **ask** user (use existing / rename / cancel)
3. Else `create_environment` with `environmentName: {slug}`
4. Resolve secret values from the hub via `op run` / `op read` into memory (or temp 0600 file)
5. `append_variables` with `concealed: true` for API keys
6. Confirm `{repo}/.env` is **not** git-tracked; if a plain file exists at that path, remove it only after user confirmation if it has unique content — prefer empty/absent before mount
7. `create_local_env_file` with absolute `mountPath: {repo}/.env`
8. Verify: `list_local_env_files` shows enabled mount; `list_variables` shows expected names; `ls -l .env` is a FIFO (`prw…`)
9. Delete temp secret files

Opt-out phrases only: “without mounting”, “do not mount”, “skip the mount”.

### 3. Keep hub and Environment in sync

On rotation or key add:

1. Update vault hub fields first
2. `append_variables` (or replace via Environments UI if append-only is insufficient)
3. Update `.env.op` + `CREDENTIALS.md` provenance
4. Remount only if mount path/name changed

## Rotation (later)

1. Mint project-owned keys at the provider
2. Update hub fields + Environment variables
3. Set `bootstrap_status=rotated` in hub notes
4. Leave develop/WorkHorse originals until intentionally retired

## Reference

- Templates, notes, Environment payload tips: [reference.md](reference.md)
- Day-to-day op: [`op-credentials`](../op-credentials/SKILL.md)
- Environments MCP mount rules: Cursor skill `1password-environments`
- Device key naming: `~/projects/secrets-management/inquiry/standards/desktop-api-keys.md`
