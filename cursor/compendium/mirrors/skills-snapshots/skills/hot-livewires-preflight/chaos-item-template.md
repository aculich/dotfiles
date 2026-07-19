# Chaos vault item template

Account: `OP_ACCOUNT=my.1password.com`  
Vault: **`chaos`** (transition inventory: LEGACY found **and** ACTIVE trials)  
Canonical durable inject vault remains **`develop`** (promote on graduation only).

## Title

```text
LEGACY · <service> · <host-or-project> · found <YYYY-MM-DD>
ACTIVE · <provider> · <tool-or-client-name> · <gcp_or_host> · <YYYY-MM-DD>
```
## Create (prefer template / stdin — avoid secret on argv)

```bash
OP_ACCOUNT=my.1password.com op item template get "API Credential" > /tmp/chaos-item.json
# Edit fields: title, credential, username/client_id as needed
# Fill notes from NOTES TEMPLATE below
OP_ACCOUNT=my.1password.com op item create --vault chaos --template /tmp/chaos-item.json
rm -f /tmp/chaos-item.json
```

Tags: `chaos-containment`, `livewire`, `needs-rotation` (if unused elsewhere), `shared-<project>` when reused, `<service>`  
ACTIVE tags: `chaos-containment`, `active-trial`, `google-oauth` (or service), `gcp:<project>`

## Watchtower / dates

- **ACTIVE trials:** set `expires` ≈ today + 90 days (`op item edit ID --vault chaos expires=YYYY-MM-DD`). Reminder only — not auto-revoke.
- **LEGACY shared:** do **not** set short expiry. Notes line: `watchtower: inventory-not-expiry`. Delete epoch-zero dates: `expires[delete]=true` and `valid from[delete]=true`.
- Login items for trials: no API expiry; link ACTIVE id in notes.

## Notes template (required)

```markdown
## Finding
- **Type:** <Google OIDC client_secret | AWS access key | …>
- **Status:** legacy-reusable-until-rotated | legacy-reusable-elsewhere | active-trial | do-not-use | rotated | revoked
- **Found (UTC):** <ISO-8601>
- **Scanners:** gitleaks, trufflehog, …

## Locations
- <absolute filepath 1>
- <absolute filepath 2>

## Machine
- Hostname: <hostname>
- LocalHostName: <scutil>
- Hardware UUID: <ioreg or system_profiler if available>

## Provenance
- develop vault: <item id/title> | no match
- Filesystem origin (if known): <path e.g. continuous-ai/credentials/…>
- Predecessor / successor chaos ids (if any)

## Leak surfaces
- SpecStory / chatstory / agent transcript paths (if any)

## Watchtower
- ACTIVE: expires YYYY-MM-DD (+90d trial nudge)
- LEGACY shared: watchtower: inventory-not-expiry

## Rotation
- See ROTATION-PLAN.md at <path>
- Provider console: <URL>
```
