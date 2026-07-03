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

- **Do NOT work around** if `op` fails (e.g. "You are not signed in", session expired, or 1Password prompts for fingerprint / system auth).
- **Do NOT** suggest pasting the secret into `.env`, hardcoding it, or using a fallback value so the command "works."
- **Do:** Report the error clearly to the user. Tell them that 1Password may be waiting for them to complete auth (e.g. fingerprint or unlock). Ask them to sign in to 1Password, complete the prompt, or fix the item/vault, then tell you when done so you can retry.
- **Wait for the user** to resolve auth or the item. Do not assume the key is "missing" and suggest creating a new one elsewhere unless the user asks.

## Account and vault

- **Always prefix every `op` command** with **`OP_ACCOUNT=my.1password.com`** when targeting this account. Example:
  - `OP_ACCOUNT=my.1password.com op item list --vault develop`
- **Vault:** Use the **develop** vault unless the user specifies another.

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
