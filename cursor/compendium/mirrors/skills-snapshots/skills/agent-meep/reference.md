# agent-meep — reference

Canonical normative text lives in the secrets-management inquiry tree. Prefer that file if both diverge.

**Source of truth:** `~/projects/secrets-management/inquiry/standards/agent-credential-escalation.md`

## Normative rules

1. Secrets for this job come only from **documented inject paths** for this workspace (`op run`, 1Password Environment, Infisical project env, sandbox credential proxy, or values the human explicitly pasted for *this* session).
2. On **missing env var** or **provider auth failure**: do not continue the spend path; do not search outside the workspace for credentials.
3. **Never** read live secrets from sibling repos, `$HOME` secret caches, or other projects' `.env` / `.env.*` files — including “temporary” use written under `/tmp`.
4. Reading `.env.example` / docs for **variable names** is fine; reading live values from foreign trees is not.
5. If the human later authorizes another vault or project, treat that as a **new scoped instruction**, not permission to use “any key that works.”

## Paste block (AGENTS.md)

```markdown
## Credentials and missing secrets

- Use only secrets provisioned for **this workspace** via the documented inject path
  (`op run`, 1Password Environment, Infisical, sandbox credential proxy, or an
  explicit human paste for this session).
- If a required credential is missing or an API call returns auth failure:
  1. Stop the path that would spend or call the provider.
  2. Report what you tried **inside this workspace** (env names checked, inject
     commands attempted, files read under the project root).
  3. Ask the human to provision or authorize the correct key.
- Do **not** search sibling projects, `$HOME`, or other repos for `.env` files or
  API keys. Do not “borrow” a key from another local project, even into `/tmp`,
  even if that would unblock the task.
- `.env.example` and docs may be used for variable **names** only.
- Billing caps elsewhere do not authorize cross-project key use.
```

## Related landscape

- Analysis: `~/projects/secrets-management/inquiry/analysis/2026-07-29-agent-borrowed-sibling-api-key.md`
- Blog draft: `~/projects/secrets-management/inquiry/blog/001-agent-mise-en-place.md`
- GWT Tier A: `~/tools/google-workspace-tools/blog/06-tiered-secrets-agentic-era.md`
