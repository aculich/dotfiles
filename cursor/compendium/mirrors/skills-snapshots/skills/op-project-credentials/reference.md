# Reference — project credentials hub + Environment

## Notes skeleton (vault hub)

```text
Project credentials hub for {slug}.

Status: BOOTSTRAP COPY — rotate soon to project-owned keys.

Updated: {ISO8601_UTC}
Vault: personal-ops (preferred). Related: develop (legacy), workhorse/sidequest (device).
Environment: {slug} (mounted at {repo}/.env)

=== Provenance ===
- {ENV}: bootstrapped from `{op://vault/uuid-or-title/field}` (len={n})

=== Local not copied ===
- {path} — {what it is}

=== Rotation TODO ===
- Mint project-scoped keys
- Update hub fields + Environment variables
- Set bootstrap_status=rotated
```

## `.env.op` template

```bash
# Source of truth: personal-ops / Project - {slug}
# Item id: {id}
# Also: 1Password Environment "{slug}" mounted at ./.env
# Usage (CLI inject): OP_ACCOUNT=my.1password.com op run --env-file .env.op -- <command>
# Usage (dotenv): rely on mounted .env FIFO — do not cat it

OPENAI_API_KEY=op://personal-ops/Project - {slug}/OPENAI_API_KEY
ANTHROPIC_API_KEY=op://personal-ops/Project - {slug}/ANTHROPIC_API_KEY
GEMINI_API_KEY=op://personal-ops/Project - {slug}/GEMINI_API_KEY
```

## `CREDENTIALS.md` skeleton

Include both access paths:

```markdown
# Credentials

**Vault hub:** `personal-ops` / `Project - {slug}` (`{id}`)  
**Environment:** `{slug}` (mounted at `.env`)

## Usage

\`\`\`bash
# A) op inject
export OP_ACCOUNT=my.1password.com
op run --env-file .env.op -- <command>

# B) mounted dotenv — tools that load .env automatically
# .env is a FIFO from 1Password Environments; do not commit or cat it
\`\`\`
```

## Environment MCP sequence

```
authenticate
list_environments          # stop+ask if {slug} exists
create_environment         # environmentName={slug}
append_variables           # concealed true for secrets
create_local_env_file      # mountPath=/abs/path/to/repo/.env
list_local_env_files       # must show isEnabled + mountPath
list_variables             # names only
```

Account id comes from `authenticate` (`account_id` / use as `accountId`).

## Syncing values into append_variables

1. Resolve from hub without printing:

```bash
OP_ACCOUNT=my.1password.com op run --env-file .env.op -- python3 - <<'PY'
import os, json
keys = ["OPENAI_API_KEY"]  # project keys
out = {k: os.environ[k] for k in keys}
path = "/tmp/{slug}-env.json"
open(path,"w").write(json.dumps(out)); os.chmod(path, 0o600)
for k,v in out.items():
    print(f"{k}: len={len(v)}")
PY
```

2. Pass values only into Environments `append_variables` (not into chat prose).
3. `rm -f` the temp file immediately after a successful append.

## Mount verification

```bash
ls -l .env          # expect prw------- (FIFO)
file .env           # expect "fifo (named pipe)"
# Do NOT: cat .env | Read .env | open in editor for contents
```

## Create vault hub via template

1. `op item template get "API Credential" > /tmp/hub.json`
2. Mutate existing username/credential fields — do not duplicate them
3. Append CONCEALED custom fields per env var
4. `op item create --vault personal-ops --template /tmp/hub.json --format json`
5. `rm -f /tmp/hub.json`

## Resolve WorkHorse by UUID

```bash
OP_ACCOUNT=my.1password.com op item list --vault personal-ops --format json \
  | python3 -c 'import json,sys
items=json.load(sys.stdin)
for i in items:
  if "WorkHorse" in i["title"] and "OPENAI" in i["title"]:
    print(i["id"], i["title"])'
```

Then: `op read "op://personal-ops/{FULL_ID}/credential"`.
