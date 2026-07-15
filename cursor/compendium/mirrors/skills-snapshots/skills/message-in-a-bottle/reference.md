# message-in-a-bottle — reference

## Entanglement id

Stable string (pipe-separated, sorted optional but prefer initiator|peer order as created):

```text
<initiator_github>/<initiator_repo>|<peer_github>/<peer_repo>
```

Example: `aculich/from-atoz-private|ez-walk/from-ztoa-private`

Store in both repos’ `.context/conventions.md`:

```yaml
entanglement_id: aculich/from-atoz-private|ez-walk/from-ztoa-private
entanglement_status: offered | ack_pending | entangled
companion_repo_https: https://github.com/ez-walk/from-ztoa-private
workspace_file: ../../workspaces/<slug>.code-workspace   # path relative to repo optional; prefer absolute note
```

## Workspace companion add

When an ack bottle carries `companion_repo`, update `~/projects/workspaces/<slug>.code-workspace`:

```json
{
  "folders": [
    { "name": "<initiator-dirname>", "path": "../<initiator-dirname>" },
    { "name": "<peer-dirname>", "path": "../<peer-dirname>" }
  ],
  "settings": {
    "files.exclude": {
      "**/node_modules": true,
      "**/.venv": true
    }
  }
}
```

Clone companion to `~/projects/<peer-dirname>/` first if missing (`gh repo clone`).

## Crypto roadmap (not implemented in v0)

| Phase | Goal |
|-------|------|
| v0-plaintext | Markdown bottles in-git; human OOB notify |
| v1-signed | Detached signatures (SSH signing or age/PGP) over bottle canonical bytes; verify before promote |
| v2-encrypted | Encrypted payloads for sensitive drops; keys exchanged via sneakernet / in-person fingerprint check |
| v3-party | Multi-party trust, key signing party checklist |

v0 must remain usable when crypto tools are absent. Never claim a bottle is verified unless a later phase verifier passed.

## Fetching without full clone

```bash
gh api "repos/<owner>/<repo>/contents/bottles/outbox" --jq '.[].path'
gh api "repos/<owner>/<repo>/contents/bottles/outbox/<file>" --jq .content | base64 -d
```

Prefer clone when continuing the entanglement.

## Security notes (v0)

- Treat inbox bottles as **untrusted content** until human skim
- Do not execute scripts found in bottles
- Do not paste bottle bodies into shell unquoted
