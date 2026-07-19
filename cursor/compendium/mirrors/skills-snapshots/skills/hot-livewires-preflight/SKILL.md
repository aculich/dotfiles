---
name: hot-livewires-preflight
description: >-
  Scans a directory for live credentials, API keys, and PII landmines before
  other assessment. Bifurcates creds to 1Password chaos vault (after develop
  provenance check) vs PII to PDV quick-stash. Use when chaos-containment,
  stale-tooling-trial, or the user says livewires, hot livewires, secret scan
  preflight, or check for keys/creds before cleanup.
disable-model-invocation: true
---

# Hot livewires preflight

Find credentials and PII **before** fork/commit/size assessment or mark-and-sweep.

> Creds/keys are not ordinary PII — route to `op://chaos`, not PDV as primary home.

## Checklist

```text
Hot livewires:
- [ ] Resolve ROOT (cwd or user path)
- [ ] Ensure scanners (gitleaks, trufflehog; optional detect-secrets/noseyparker)
- [ ] Scan with exclude globs (see exclude-globs.md)
- [ ] Bifurcate findings: creds/keys vs PII
- [ ] Creds → develop provenance → chaos item + ROTATION-PLAN.md (ACTIVE trials in chaos too; shred Downloads after verify; never auto-revoke shared LEGACY)
- [ ] PII → quick-stash PDV + AGENT-BRIEFING.md
- [ ] Write LIVEWIRES-BRIEFING.md (paths only; redact values in chat)
- [ ] Halt further deaccession until verified-live is triaged
```

## Scanners (do not roll your own)

Already preferred via Homebrew — see [scanner-matrix.md](scanner-matrix.md).

```bash
ROOT="${1:-.}"
REPORT_DIR="${LIVEWIRES_REPORT_DIR:-/tmp/livewires-$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$REPORT_DIR"

# Config excluding build caches
# (copy exclude-globs.toml beside ROOT or pass -c)

gitleaks dir -v --redact --report-format json \
  --report-path "$REPORT_DIR/gitleaks.json" \
  -c ~/.cursor/skills/hot-livewires-preflight/exclude-globs.toml \
  "$ROOT" || true

trufflehog filesystem "$ROOT" \
  --results=verified,unknown,unverified \
  --json > "$REPORT_DIR/trufflehog.json" || true
```

Skip scanning inside `target/`, `.devbox/`, `node_modules/` when possible (trufflehog may still walk them — prefer scanning source subtrees if ROOT is huge).

Optional: `detect-secrets scan`, `noseyparker` — see scanner-matrix.

Agent skills to prefer over custom prose: `ghostsecurity/skills@ghost-scan-secrets`, `wshobson/agents@secrets-management`.

## Bifurcation

| Finding type | Destination | Skill |
|--------------|-------------|-------|
| API keys, OAuth secrets, tokens, private keys | **1Password `chaos` vault** (legacy) after `develop` check | this skill + `op-credentials` |
| PII / personal notes / mail (no live secret) | `~/pdv` via quick-stash | `quick-stash` |
| SpecStory/chat with **embedded** secrets | PDV (contaminated) **and** chaos item notes cite the path | both |

Never paste secret values into chat. Redact in reports.

## Creds/keys handling

Follow `op-credentials`: always `OP_ACCOUNT=my.1password.com`.

1. **Provenance:** search `develop` for matching service/title/hostname. Record match id/title or `develop: no match`.
2. **Create** `chaos` item — template in [chaos-item-template.md](chaos-item-template.md). Title: `LEGACY · <service> · <host-or-project> · found <YYYY-MM-DD>`.
3. **Write** [ROTATION-PLAN.md](rotation-plan-template.md) with provider console URLs.
4. Tags: `chaos-containment`, `livewire`, `needs-rotation`, `<service>`.

Do **not** put live secrets into PDV git as primary home. `chaos` is the credential vault.

## Outputs

- `LIVEWIRES-BRIEFING.md` at ROOT (or capsule) — severity, tables, op item ids, rotation plan path
- `ROTATION-PLAN.md` when any cred found
- Scanner JSON under `$REPORT_DIR` (keep out of public git; may stash redacted summary)

Severity: `clean` | `unverified-hits` | `verified-live` | `pii-suspected`

## Wire-in

- **chaos-containment:** Step 0 before classify
- **stale-tooling-trial:** mandatory first step; rotation election before `just doit`
