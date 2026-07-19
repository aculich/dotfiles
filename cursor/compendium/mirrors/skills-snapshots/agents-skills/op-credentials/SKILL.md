---
name: op-credentials
description: Use 1Password CLI (op) for API keys and credentials. Trigger when API_KEY, OPENAI_API_KEY, or any credential access is needed. Use op properly; on failure do not work around—report to user and wait for them to auth (e.g. fingerprint) or fix.
---

# 1Password credentials (op CLI)

## When to use (trigger)

- **Any time the conversation involves API keys or credential access:** e.g. `API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `CLERK_SECRET_KEY`, or any `*_API_KEY` / secret needed to run a command, quickstart, or script. Use this skill so keys are obtained via `op` in a consistent way.
- User asks to run a quickstart, set up keys, use credentials, or manage API keys.
- User asks to add a token, secret, or API key to 1Password (e.g. "add to 1password", "store in 1Password").
- Any time you run the `op` CLI (read, create, list, inject, run): follow this skill so the correct account is used.

## If op fails (auth / fingerprint) — no workarounds

- **Do NOT work around** if `op` fails (e.g. "You are not signed in", session expired, authorization timeout, or 1Password prompts for fingerprint / system auth).
- **Do NOT** suggest pasting the secret into `.env`, hardcoding it, or using a fallback value so the command "works."
- **Do NOT change the plan** because auth failed. Auth failure is almost always “human wasn’t looking at the unlock prompt” — not a signal to redesign vault topology or skip chaos intake.
- **Do:** Check in with the human clearly: unlock 1Password / approve biometric, then say when ready. Retry the **same** command.
- **Wait for the user** to resolve auth or the item. Do not assume the key is "missing" and suggest creating a new one elsewhere unless the user asks.

## Account and vault

- **Always prefix every `op` command** with **`OP_ACCOUNT=my.1password.com`** when targeting this account. Example:
  - `OP_ACCOUNT=my.1password.com op item list --vault develop`
- **Vaults:**
  - **`develop`** — canonical **working** credentials for durable day-to-day inject (default for graduated apps)
  - **`chaos`** — **transition / containment inventory**: LEGACY found secrets **and** ACTIVE trial clients for personal catchall work. Annotate `gcp:<project_id>`, tool path, vintage, status. Not a kill switch — shared LEGACY often stays live until drain-the-swamp ([DEACCESSIONING-GUIDE](file:///Users/me/pdv/meta/DEACCESSIONING-GUIDE.md)).
- Use **`develop`** for elevated/daily inject. Use **`chaos`** for found LEGACY and for new per-tool ACTIVE trial clients until the tool graduates.

## Found credentials (chaos vault)

When `hot-livewires-preflight` or chaos-containment discovers API keys / OAuth secrets in a tree:

1. Search **`develop`** for provenance (title/service/hostname). Do not mutate `develop` unless the user asks.
2. Create a **new** item in **`chaos`** — title `LEGACY · <service> · <host-or-project> · found <YYYY-MM-DD>`.
3. Category: `API Credential`. Prefer template/stdin for the secret (see below).
4. Notes must include: type, absolute filepaths, machine hostname/LocalHostName/UUID, found UTC + scanners, develop match or filesystem origin, SpecStory/chatstory leak surfaces, status (`legacy-reusable-until-rotated` | `legacy-reusable-elsewhere` | `do-not-use` | `rotated` | `revoked`).
5. Tags: `chaos-containment`, `livewire`, `needs-rotation` (if unused elsewhere), `shared-<project>` when reused across tools, `<service>`.
6. Write `ROTATION-PLAN.md` with provider console URLs. For personal trials, mint **ACTIVE** clients into **`chaos`** (not develop) until graduation. **Do not** revoke shared LEGACY when only one consumer rotates — see deaccession guides-and-guards.

### ACTIVE trial clients (also chaos)

Title: `ACTIVE · <provider> · <tool-or-client-name> · <gcp_or_host> · <YYYY-MM-DD>`.  
Intake Downloads JSON: create → op readback/diff → **shred immediately**. Link predecessor LEGACY in notes.  
**Watchtower:** set `expires` ≈ +90 days on ACTIVE API Credentials (trial nudge). LEGACY shared: notes `watchtower: inventory-not-expiry` — no short TTL.

Template details: `~/.cursor/skills/hot-livewires-preflight/chaos-item-template.md`.

```bash
OP_ACCOUNT=my.1password.com op item list --vault chaos
OP_ACCOUNT=my.1password.com op item template get "API Credential" > /tmp/chaos-item.json
# edit template, then:
OP_ACCOUNT=my.1password.com op item create --vault chaos --template /tmp/chaos-item.json
rm -f /tmp/chaos-item.json
```

After a tool **graduates**: promote inject refs to `op://develop/...`. Provider-revoke LEGACY only via explicit `apply-revoke` after drain-the-swamp inventory (never same-day because one ACTIVE succeeded).

### Graduation ladder

```text
chaos + Watchtower (+90d ACTIVE)  →  develop  →  optional Infisical/Doppler/Vault/cloud SM
```

Personal transition stays on 1Password. Landscape note: [`~/pdv/meta/notes/2026-07-18-agentic-secrets-landscape.md`](file:///Users/me/pdv/meta/notes/2026-07-18-agentic-secrets-landscape.md). Do not install peer vaults unless the user asks.

## Reading keys

- **Single field:**  
  `OP_ACCOUNT=my.1password.com op read "op://develop/ITEM_NAME/credential"`
- **Inject into a file (e.g. .env):** Use a template with `op://` references, then:  
  `OP_ACCOUNT=my.1password.com op inject -i .env.template -o .env`
- **Inject into a command:** Use an env file with secret references (e.g. `OPENAI_API_KEY=op://develop/OpenAI/credential`), then:  
  `OP_ACCOUNT=my.1password.com op run --env-file .env.op -- <command>`

## Listing items

- `OP_ACCOUNT=my.1password.com op item list --vault develop`

## Adding a new API key or credential

- **Category:** "API Credential".
- **Secret:** Prefer supplying via a JSON template or stdin; avoid passing the secret on the command line when possible. If the user provides a value and you must use the CLI, use the prefix:
  - `OP_ACCOUNT=my.1password.com op item create --vault develop --category "API Credential" --title "Item Title" credential="SECRET_VALUE"`
- **Metadata:** Include key management URL, documentation URL, or hostname when useful. For structured creation use `OP_ACCOUNT=my.1password.com op item template get "API Credential"` to get the base template, then create with `op item create --template <file> --vault develop`; remove the template file after create.

## Best practices

- No plaintext secrets in the repo or in shell history when avoidable.
- One 1Password item per app/service when possible; use `op inject` with `.env.template` for app env (e.g. Clerk keys).
- Use secret references in env files and `OP_ACCOUNT=my.1password.com op run --env-file .env.op -- <command>` to inject into commands.
