# Scanner matrix

| Tool | Install | Role | Primary command |
|------|---------|------|-----------------|
| gitleaks | `brew install gitleaks` | Fast dir/git rules; sees gitignored files | `gitleaks dir -v --redact -r report.json -f json PATH` |
| trufflehog | `brew install trufflehog` | Detect + verify live credentials | `trufflehog filesystem PATH --results=verified,unknown,unverified --json` |
| detect-secrets | `brew install detect-secrets` | Baseline inventory | `detect-secrets scan --all-files` |
| noseyparker | `brew install noseyparker` | Large-tree deduped scan | `noseyparker scan -d datastore PATH && noseyparker report -d datastore` |

## Agent skills (prefer over custom scanners)

| Skill | Install |
|-------|---------|
| ghost-scan-secrets | `npx skills add ghostsecurity/skills@ghost-scan-secrets -y` |
| secrets-management | `npx skills add wshobson/agents@secrets-management -y` |
| pii-detect (optional) | `npx skills add ruvnet/ruflo@pii-detect -y` |

## Rotation sidequest (recommend, do not auto-install platforms)

- Infisical Secret Rotation: https://infisical.com/docs/documentation/platform/secret-rotation/overview
- HashiCorp Vault: https://www.hashicorp.com/en/products/vault
- 1Password Secrets Automation: https://developer.1password.com/docs/secrets-automation
- GitGuardian remediation: https://docs.gitguardian.com/secrets-detection/secrets-detection-engine/leaks_remediation
