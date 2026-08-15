# Client share tag reference

## Namespaces

| Prefix | Meaning | Push to GitHub |
|--------|---------|----------------|
| `client/` | Shared with partners; cite in email / Feedback Doc | Yes, when Aaron (or Tim/Reily) explicitly publishes the tag |
| `internal/` | Team checkpoints; not for client citation | Optional remote backup only |

Use **annotated** tags only. GitHub **Releases** for `client/*` (notes = same fields as the annotation). No SemVer required for drafts; date + event slug is the key. A later `client/<abbr>/v1.1.0` can sit beside dated share tags as the audit trail.

## Annotation / release body fields

```
artifact: reports/redwood_city/index.rendered.html
url: https://cidrlab.org/hprm_sanmateo/reports/redwood_city/index.rendered.html
blob_sha256: <hex>
shared_on: YYYY-MM-DD
audience: <who>
evidence: <email note / granola / STATUS path>
notes: <one line>
```

Tagger date = `shared_on`. Point the tag at the **oldest commit on `main` whose blob for `artifact` equals what was shared**.

## Tag name

`client/<abbr>/<YYYY-MM-DD>-<event-slug>`

- `<abbr>`: short jurisdiction/product key (`rwc`, `smc`, …)
- `<event-slug>`: kebab-case share moment (`roundtable`, `feedback-window`, `print-freeze`)

## Surfaces (do not equate)

| Surface | What partners see |
|---------|-------------------|
| `https://cidrlab.org/hprm_sanmateo/reports/<slug>/index.rendered.html` | Signed-off / freeze artifact on **`main`** (Pages source = `main` `/`) |
| Bare `/reports/<slug>/` (no filename) | Directory index → **`index.html`** — often a different Quarto build. **Never email this path alone.** |
| Branch `rj_sm` / local Quarto preview | Tim/Reily (or Aaron) WIP — internal until merged **and** the freeze file is intentionally refreshed |

WIP `rj_sm` ≠ freeze URL ≠ bare-directory `index.html`.

## Operating rule (next share)

1. Choose the exact file URL (default: `index.rendered.html` until policy changes).
2. Record `blob_sha256` of that file at the cited commit (`pin-freeze-blob.sh`).
3. `git tag -a client/…` → review summary → `git push origin refs/tags/client/…` only with explicit ask.
4. `gh release create` from that tag.
5. Cite in outbound mail: **tag name + full URL + short commit SHA**.
6. Append SHARELOG row; optionally snapshot HTML under `cidr-san-mateo-21elements/01-background/sources/rwc-report-snapshots/<date>/`.

## Worked RWC tags (`cidrlab/hprm_sanmateo`)

| Tag | Commit | blob_sha256 prefix | shared_on | Role |
|-----|--------|--------------------|-----------|------|
| `client/rwc/2026-07-07-v1-content` | `e1d4c07` | `ca986da3bc5e…` | 2026-07-07 | Precursor content freeze (**not** identical to live after 2026-07-14) |
| `client/rwc/2026-07-14-print-freeze` | `82c677c` | `b934c6033d45…` | 2026-07-14 | Oldest main commit whose freeze blob == live Pages |
| `client/rwc/2026-07-20-roundtable` | `82c677c` | `b934c6033d45…` | 2026-07-20 | SMC jurisdiction roundtable share event |
| `client/rwc/2026-07-31-feedback-window` | `82c677c` | `b934c6033d45…` | 2026-07-31 | Feedback Doc / written-feedback deadline |

Releases: https://github.com/cidrlab/hprm_sanmateo/releases

Log: `CLIENT_SHARE_TAGS.md` in `hprm_sanmateo` (local `wip/aaron-client-tags-docs` until Tim/Reily merge).

## Footguns

- Do not retag or recreate existing `client/rwc/…` releases.
- Do not push WIP branches or deploy Pages from this skill.
- A live URL whose sha256 is missing from `origin/main` means Pages and git have diverged — fix that before tagging.
- `internal/rj_sm/…` is local-only unless Aaron asks to push it.
