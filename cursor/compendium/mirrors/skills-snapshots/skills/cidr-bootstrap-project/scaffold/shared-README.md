# `shared/` — outbound bundle provenance

Files we send to funders, county partners, courts, or advisors get a **timestamped manifest** here so we can reconstruct which version went out, when, and to whom.

## What goes here

- `shared/manifests/YYYYMMDDTHHMMSSZ.yaml` — manifest for one outbound bundle (commit these).
- `shared/sow/<tag>` — annotated git tags marking the exact commit that produced a shared SOW PDF (commit these).
- `shared/gdrive-downloads/` — local cache of files we round-tripped from Drive (gitignored).
- `shared/*.eml` — local archive of the actual outbound message we sent (gitignored).

## Manifest format

```yaml
---
share_id: SHARE-YYYY-NNN
timestamp: YYYY-MM-DDTHH:MM:SSZ
sender: aaron@cidrlab.org
recipients:
  - name: First Last
    email: x@y.org
    org: Org
purpose: <one-liner — why this went out>
artifacts:
  - path: 02-request-materials/scope-of-work.md
    git_sha: <commit sha>
    sha256: <hash>
  - path: 02-request-materials/scope-of-work.pdf
    sha256: <hash>
related_comms: 02-request-materials/communications/YYYY-MM-DD-NNN-*.md
notes: |
  Optional context on what changed since the last share.
---
```

## Skills

- **`cidr-bootstrap-project`** seeds this folder.
- The optional `make share-sow` target (copy from cidr-marin-courts/Makefile) automates timestamping and manifest creation for SOW shares.
