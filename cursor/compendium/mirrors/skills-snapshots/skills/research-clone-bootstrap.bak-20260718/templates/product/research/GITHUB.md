# GitHub / remotes — {{SLUG}}

## Product repo (this tree)

Private recommended until publish:

```bash
cd product
gh repo create <you>/{{SLUG}} --private --source=. --remote=origin --push
```

## Peer clones

Not committed to the product repo. Managed under `../peers/` via `repos.txt` + `sync.sh`.

## Optional upstream fork

If implementing via fork of an OSS peer, use a **separate** private git remote (like Jumpkey's `jumpkey-alt-tab`), and add that worktree to the **product** workspace only after you intend to ship from it.
