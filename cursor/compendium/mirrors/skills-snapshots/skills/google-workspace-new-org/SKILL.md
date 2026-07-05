---
name: google-workspace-new-org
description: Bootstraps a new independent Google Workspace org end-to-end — 1Password vault, GCP admin/default/webapp projects, Firebase, gog/gws/GAM, DWD, DNS, isolated auth browser, optional Render hosting. Use when adding a new domain/org, running stem-to-stern Workspace setup, or extending google-workspace-tools for a new org slug.
---

# New Google Workspace org (stem-to-stern)

Extend `~/tools/google-workspace-tools` for a new org. **OfficialsPay** and **Emerging Patterns** are reference implementations.

## Inputs (gather first)

| Variable | Example |
|----------|---------|
| `ORG_SLUG` | `emergingpatterns` |
| `DOMAIN` | `emergingpatterns.ai` |
| `ADMIN_EMAIL` | `admin@emergingpatterns.ai` |
| `VAULT_NAME` | `emergingpatterns.ai` |
| `PROJECT_PATH` | `/Users/me/projects/emergingpatterns` |
| `DNS_PROVIDER` | `dnsimple` \| `namecheap` \| `squarespace` |

## Naming (copy table)

| Tier | GCP project | gcloud config | gog client |
|------|-------------|---------------|------------|
| Admin | `{ORG_SLUG}-admin` | `{ORG_SLUG}` | `{ORG_SLUG}` |
| Default | `{ORG_SLUG}-default` | same | — |
| Webapp | `{ORG_SLUG}-prod` | same | app-specific |

gog alias: `{ORG_SLUG}-admin` → `ADMIN_EMAIL`. GAM: `~/.config/gam-profiles/{ORG_SLUG}`. gws: `~/.config/gws-{ORG_SLUG}-admin/`.

## Files to create

- `docs/{ORG_SLUG}-setup.md`
- `scripts/{ORG_SLUG}-setup-check.sh` (copy from `officialspay-setup-check.sh`)
- `scripts/{ORG_SLUG}-register-oauth-client.sh`
- `scripts/auth-browser/open-{ORG_SLUG}-auth.sh`
- DNS script if DNSimple (`{ORG_SLUG}-dns-dnsimple-targets.sh`)

## Files to extend

- `scripts/lib/workspace-common.sh` — `EXPECTED_ACCOUNTS`, `gog_preferred_client_for_email`
- `justfile` — `{ORG_SLUG}`, smoke, oauth-register, dns recipes
- `scripts/setup-gcp-per-org.sh`, `dwd-setup-org.sh`, `dwd-verify-org.sh`
- `scripts/lib/firebase-org-map.sh`, `google-workspace-cli-aliases.zsh`
- `scripts/dns-email-audit.sh`, `docs/gcp-project-layout.md`, `docs/NEW_MACHINE.md`, `docs/CREDENTIALS.md`
- `examples/cursor-rules/{ORG_SLUG}-google-workspace.mdc` in project repo

## Execution order

```bash
just gcp-setup && just gcp-auth-admin
# Create *-admin, *-default, *-prod in GCP Console as ADMIN_EMAIL
just {ORG_SLUG}-oauth-register
just gog-auth-login ADMIN_EMAIL --client ORG_SLUG
just gcloud-auth-login ADMIN_EMAIL
just gam-oauth-create ORG_SLUG
just dwd-setup ORG_SLUG --create-key --store-op
just dwd-wire ORG_SLUG && just dwd-verify ORG_SLUG
just firebase-auth-login ADMIN_EMAIL
just {ORG_SLUG} && just {ORG_SLUG}-smoke
```

## Browser isolation

- `WORKSPACE_AUTH_ENGINE=chrome`
- `scripts/auth-browser/workspace-auth-run.sh` for all OAuth
- Never use personal Chrome profiles for org admin login

## DNS providers

- **DNSimple:** reuse `scripts/lib/dnsimple-api.sh`; creds often in `develop` vault
- **Namecheap:** manual + `docs/templates/namecheap-dns-handoff-*.md`
- **Squarespace:** see `docs/squarespace-hosting.md`

## Render (optional web runtime)

If app deploys on Render (not Firebase Hosting): [render-hosting.md](file:///Users/me/tools/google-workspace-tools/docs/render-hosting.md).

- ALIAS apex → `*.onrender.com` (not third-party proxy like `*.polsia.app`)
- Preserve Workspace MX when updating web DNS
- Store Render hostname in 1Password before DNS apply

## Validation

```bash
just {ORG_SLUG}
just dwd-verify {ORG_SLUG}
just dns-audit DOMAIN
```

## Worked example

[emergingpatterns-setup.md](file:///Users/me/tools/google-workspace-tools/docs/emergingpatterns-setup.md) — full values for Emerging Patterns + Polsia exit.

## Reference

- [reference.md](reference.md) — file diff checklist vs OfficialsPay
- [examples.md](examples.md) — Emerging Patterns invocation
