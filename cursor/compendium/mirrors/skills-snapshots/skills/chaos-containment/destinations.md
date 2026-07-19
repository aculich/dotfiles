# Destinations

> Never drop data without its context and intent — leave a capsule, not a dig site.

Decision aid for `/chaos-containment offload`. Ethos: `~/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md`.

## Decision tree

1. **Live credentials / API keys / OAuth secrets?** → **1Password `chaos` vault** via `hot-livewires-preflight` (check `develop` first; write `ROTATION-PLAN.md`). Not ordinary PII.
2. Else **Sensitive / PII / personal notes?** → **PDV** via `quick-stash` + `AGENT-BRIEFING.md`
3. Else **must stay coupled to this git project** (CI/build/repro)? → **git-lfs** or **DVC** (ask first) + pointer README
4. Else **loose archival / research corpus**? → **Google Drive** via attached workspace `gog-as` + `OFFLOAD.md`
5. Else **vendor/upstream source?** → leave in place; document with `vendor-map` — do not offload to PDV

## 1Password `chaos` vault (found credentials)

- Account: `OP_ACCOUNT=my.1password.com`
- Vault: **`chaos`** — `/chaos-containment destination for found credentials`
- Canonical **working** secrets stay in **`develop`**
- Skill: `hot-livewires-preflight` + `op-credentials`
- Create `LEGACY · …` API Credential items with notes (paths, machine, provenance, rotation status)
- Do **not** use PDV git as the primary home for live secret values

## PDV (`~/pdv`)

```bash
VAULT_ROOT="${PDV_ROOT:-${VAULT_ROOT:-$HOME/pdv}}"
```

- Landing: `$VAULT_ROOT/partitions/default/capsules/flotsam-and-jetsam/misc/vintage-YYYY-MM/`
- Skills: `quick-stash` (new uncommitted), `tidy-stash` (existing/committed clutter)
- **Required:** vintage README provenance **and** `AGENT-BRIEFING.md`
- Do not confuse with Obsidian `~/vaults`

## Google Drive

1. Read project `.workspace-tools.json` → `gog_alias`, `org`, `deny_orgs`
2. If no manifest: prompt `attach-workspace <org>` (from google-workspace-tools aliases)
3. Respect **org isolation** — do not upload to a foreign org from a bound workspace without explicit override
4. Suggested remote folder: `Chaos-Containment/<repo-basename>/<YYYY-MM>/`
5. Local stub: `OFFLOAD.md` with steward one-liner, whence, purpose, Drive URL/path, sensitivity
6. Remove or gitignore local bytes only after user confirm

```bash
# After aliases are sourced and workspace is attached:
gog-as <alias> drive ls   # sanity
# then upload per gogcli drive conventions for the installed version
```

## git-lfs

Use when large files must remain addressable from the repo for builds/tests.

- Ask before introducing LFS to a repo that does not already use it
- Track patterns; commit pointers; document in a short README (one-liner)
- Not a substitute for PDV for PII

## DVC

Use when datasets need reproducible pipelines / remotes separate from git objects.

- Ask before introducing DVC
- `.dvc` + remote config; pointer README (one-liner)
- Not a substitute for PDV for PII

## Anti-patterns

- PDV for public OSS vendor clones
- PDV as primary store for live API keys (use `chaos` + rotate into `develop`)
- Drive for secrets/PII that belong in PDV or `chaos`
- LFS/DVC for one-off personal clutter
- Cross-org Drive without attach + isolation check
