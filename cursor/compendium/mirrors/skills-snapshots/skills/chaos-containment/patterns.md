# Offload / destination patterns

> Never drop data without its context and intent — leave a capsule, not a dig site.

Living catalog for `/chaos-containment offload`. When a new destination or transport appears mid-run, **append** a row (or section) here.

## Seed patterns

### OSS vendor / upstream clones

- **Signals:** `owner__repo`, `vendors/`, `upstream/`, nested `.git` that is clearly third-party
- **Destination:** stay in tree as gitignored or pinned vendor; do **not** send to PDV
- **Transport:** none (document via `vendor-map`)
- **Briefing:** optional short note in vendor-map / README with one-liner if relocating
- **Example:** `Ice__jordanbaird`, `macos-golden-config/vendors/`

### Research paper / pricing / extraction dumps

- **Signals:** PDFs, `*pricing*.json`, paper corpora, search-archives, bulk extraction results
- **Destination:** org Google Drive (loose archival) unless tightly coupled to CI
- **Transport:** `gog-as <alias> drive …` after `.workspace-tools.json` / `attach-workspace`
- **Briefing:** local `OFFLOAD.md` with one-liner + Drive path
- **Example:** root `*-prices-2026.json`, research paper downloads

### PII / personal / secrets

- **Signals:** affiliations, mail `.eml` with personal content, credentials, non-OSS personal notes
- **Destination:** `~/pdv` flotsam vintage via `quick-stash`
- **Transport:** `mv` into vintage; vault commit
- **Briefing:** **required** `AGENT-BRIEFING.md`
- **Example:** collaborator affiliation JSON, personal research dumps

### Research-clone labs (product + peers)

- **Signals:** `labs/<slug>/product`, `peers/clones`, `*-research.code-workspace`
- **Destination:** keep lab structure; offload only heavy clone/download blobs if needed
- **Transport:** per research-data or vendor pattern
- **Briefing:** OFFLOAD or AGENT-BRIEFING as destination dictates
- **Example:** `labs/raycast/`, `research-clones/`

### Build artifacts

- **Signals:** `node_modules`, `.next`, `dist`, derived caches
- **Destination:** delete or gitignore — **never** vault or Drive as archives of dependency trees
- **Transport:** `rm` only after explicit confirm (or rely on existing gitignore)
- **Briefing:** not applicable

### Secrets / PII preflight (hot livewires)

- **Signals:** Before any containment classify; or when user asks about keys/creds landmines
- **Destination:** creds → `op://chaos`; PII → PDV quick-stash
- **Transport:** `hot-livewires-preflight` (gitleaks + trufflehog); `op item create --vault chaos`
- **Briefing:** `LIVEWIRES-BRIEFING.md` + `ROTATION-PLAN.md`
- **Example:** `macosx-tools/universal-inbox/` Google OIDC in `local.toml`
- **Added:** 2026-07-18 — context: stale tool deaccession

### Stale tooling trial under umbrella

- **Signals:** Nested third-party `.git`, personal wrapper scripts/docs, multi-GB `target`/`.devbox`, `.specstory`, untracked under umbrella
- **Destination:** mark-and-sweep old path; fresh `~/tools/<tool>-quickstart/` via tools-quickstart-bootstrap
- **Transport:** preserve capsule → `MARK-AND-SWEEP.md` → bootstrap → rotation election → `just doit`
- **Briefing:** required for SpecStory/PDV; chaos items for creds
- **Example:** `macosx-tools/universal-inbox/`
- **Added:** 2026-07-18 — context: stale tool deaccession

### Creds → op://chaos (legacy) vs PII → PDV

- **Signals:** Livewire finding classified as API key / OAuth / token vs personal PII without secret
- **Destination:** `chaos` vault vs `~/pdv`
- **Transport:** op CLI vs quick-stash
- **Briefing:** chaos item notes + ROTATION-PLAN; or AGENT-BRIEFING for PDV
- **Added:** 2026-07-18 — context: chaos vault created for containment

### Build-coupled large assets

- **Signals:** assets the app/CI must fetch to build or test; reproducible datasets
- **Destination:** git-lfs or DVC (ask before introducing)
- **Transport:** lfs track / dvc add + remote
- **Briefing:** pointer README with one-liner
- **Example:** large fixtures that must version with the product

---

## How to append a new pattern

```markdown
### <Name>

- **Signals:** …
- **Destination:** …
- **Transport:** …
- **Briefing:** …
- **Example:** …
- **Added:** YYYY-MM-DD — context: <repo or run>
```
