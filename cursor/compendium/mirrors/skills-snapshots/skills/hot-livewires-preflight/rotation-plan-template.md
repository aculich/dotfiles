# Rotation plan template

Copy to `ROTATION-PLAN.md` beside the scanned root (and/or PDV capsule).

```markdown
# ROTATION-PLAN — <tool-or-tree>

**Status:** pending | elected-skip | in-progress | done  
**Election:** rotate-before-doit (recommended) | skip-legacy-smoke-only

## Credentials

### 1. <service name>
- **chaos item:** op://chaos/<title-or-id>
- **develop provenance:** <id/title or none>
- **Type:** …
- **Found in:** <paths, redacted>
- **Rotate at:**
  1. <provider console URL>
  2. …
- **Steps:**
  1. Create new secret at provider
  2. Store **new** value in `develop` (canonical)
  3. Update consumers / quickstart `op://develop/…` refs
  4. Revoke old secret at provider
  5. Mark chaos item status `rotated`; remove `needs-rotation` tag

## Sidequest tooling (optional)
- Infisical: https://infisical.com/docs/documentation/platform/secret-rotation/overview
- HashiCorp Vault: https://www.hashicorp.com/en/products/vault
- 1Password Secrets Automation: https://developer.1password.com/docs/secrets-automation
- GitGuardian remediation: https://docs.gitguardian.com/secrets-detection/secrets-detection-engine/leaks_remediation

## Gate
`just doit` should not run until Status is `done` or Election is `skip-legacy-smoke-only`.
```
