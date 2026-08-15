---
name: cidr-client-share-tags
description: Create annotated `client/…` git tags and GitHub Releases that pin partner-facing report shares to an exact freeze HTML blob (commit ↔ share date ↔ live-blob check). Use when sharing HPRM/jurisdiction reports with clients, creating `client/` release tags, backdating share provenance, or when the user mentions partner share tags / Pages freeze vs WIP.
---

# cidr-client-share-tags

Pin partner-facing report shares so each email/roundtable/Feedback Doc moment maps to an exact freeze HTML blob — instead of reconstructing tags after the fact.

**Follow-up:** we’ll turn this into a Cursor skill so future partner shares can automatically create the matching `client/…` release tags (commit ↔ share timing + live-blob check) instead of reconstructing them after the fact.

Primary repo: `cidrlab/hprm_sanmateo`. Artifact default: `reports/<slug>/index.rendered.html` (slug default `redwood_city`). Schema and RWC examples: [reference.md](reference.md).

## Hard gates

1. **Collect** before tagging: `shared_on` (YYYY-MM-DD), `audience`, `evidence` (email note / granola / STATUS path), `slug` (default `redwood_city`), artifact path (default `reports/<slug>/index.rendered.html`), **full URL** (never a bare directory).
2. **Resolve commit** = oldest on `origin/main` whose artifact blob equals what is being shared. Prefer live-URL sha256 if the URL is already published; else blob at the intended freeze commit. Run:

   ```bash
   ~/.cursor/skills/cidr-client-share-tags/scripts/pin-freeze-blob.sh \
     --repo /path/to/hprm_sanmateo \
     --path reports/redwood_city/index.rendered.html \
     --url https://cidrlab.org/hprm_sanmateo/reports/redwood_city/index.rendered.html
   ```

   If live sha256 matches no blob on `origin/main`, stop — Pages is out of sync.
3. **Create an annotated tag** (never lightweight) named `client/<abbr>/<YYYY-MM-DD>-<event-slug>` with the required annotation fields ([reference.md](reference.md)). Tagger date = `shared_on` via `GIT_COMMITTER_DATE`. Multiple `client/` tags may point at the same commit (one tag per share event).
4. **Append** a row to `CLIENT_SHARE_TAGS.md` on a **local-only** `wip/aaron-…` branch. Do not push that branch.
5. **Stop and show a summary** (tag, commit, sha256, URL, citation block). Push tags + `gh release create` **only if** the user explicitly says to publish tags this turn.
6. **Never** deploy Pages; **never** push `rj_sm` / `main` / WIP branches; **never** email bare `/<slug>/` (that serves `index.html`, not the freeze).

`internal/` tags are team checkpoints only — not for client citation. Push `internal/` only if Aaron asks.

## Tag + release (after confirmation)

```bash
GIT_COMMITTER_DATE='YYYY-MM-DDTHH:MM:SS-07:00' git tag -a 'client/<abbr>/<YYYY-MM-DD>-<event>' <commit> -m "$(cat <<'EOF'
artifact: reports/<slug>/index.rendered.html
url: https://cidrlab.org/hprm_sanmateo/reports/<slug>/index.rendered.html
blob_sha256: <hex>
shared_on: YYYY-MM-DD
audience: <who>
evidence: <path>
notes: <one line>
EOF
)"

# Only after explicit publish ask:
git push origin "refs/tags/client/<abbr>/<YYYY-MM-DD>-<event>"
gh release create "client/<abbr>/<YYYY-MM-DD>-<event>" --repo cidrlab/hprm_sanmateo \
  --title "<share title>" --notes "<same fields as annotation>"
```

## Citation block (outbound mail)

```
Tag: client/<abbr>/<YYYY-MM-DD>-<event>
URL: https://cidrlab.org/hprm_sanmateo/reports/<slug>/index.rendered.html
Commit: <short SHA>
```
