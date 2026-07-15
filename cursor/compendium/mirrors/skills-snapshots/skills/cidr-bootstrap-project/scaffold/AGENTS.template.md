# Agent memory ({{PROJECT_SLUG}})

## Learned User Preferences

- Use the GitHub CLI (`gh`) for org repos and API access under the `cidrlab` and `evictionresearch` organizations when creating or updating remote resources.
- Keep machine-only artifacts out of the shared tree: use `.git/info/exclude` for Cursor hook state, personal reference copies of PDFs/docx, and other files that should not appear in a committed `.gitignore`.
- Never delete files or large code blocks without explicit confirmation.

## Learned Workspace Facts

- **Bootstrapped by** the `cidr-bootstrap-project` skill from `~/projects/cidr-marin-courts/` as the canonical reference.
- **Meeting ingest paths** (Granola `user-granola`, Zoom `user-zoom`, `incoming/*.eml` drops): read [`.context/conventions.md`](.context/conventions.md); keep **personal** and **off-scope** segments out of committed markdown and out of `.context/` (use gitignored `outofscope/` for carve-outs). Use **`meeting-sync`** for transcript ingest and **`context-engineering`** for `.context/` updates.
- **Google Workspace binding:** attached to **cidrlab** org via `just attach-project` (step 9 of bootstrap). Default identity: `aaron@cidrlab.org` / `gog-as cidrlab`. Manifest: [`.workspace-tools.json`](.workspace-tools.json). Status: `cd ~/tools/google-workspace-tools && just cidrlab`.
- **Primary remote** (when created): `cidrlab/{{PROJECT_SLUG}}` (private by default).
- **Nested gitignored sibling clones** (`evictionresearch/...`, `library/`, `upstream/...`): each has its own `.git`. Document the policy in [`ARCHITECTURE.md`](ARCHITECTURE.md). PRs go to whichever repo owns the file.
- **Optional SOW PDF flow:** if `Makefile` is copied from cidr-marin-courts, `make sow-pdf` runs `scripts/build-sow-pdf.sh` (Pandoc + XeLaTeX). Logo resolution uses vendored assets under `02-request-materials/assets/logos/` when present, otherwise fetches from `cidrlab/cidrlab.github.io` via `gh api` and converts with `rsvg-convert`.
- **Optional hooks:** repository hooks live in `.githooks/`; run `git config core.hooksPath .githooks` so commits that touch SOW or letterhead Markdown rebuild and stage the matching PDFs.
- **Privacy:** no defendant names in court communications; no racial estimation language in written SOWs; redact phone numbers and tokenized URLs in committed markdown — see [`.context/values.md`](.context/values.md) and [`.context/sensitive-topics.md`](.context/sensitive-topics.md).

## Skills to invoke

- `cidr-bootstrap-project` — created this scaffold; rerun if you restructure.
- `context-engineering` — fill or refresh `.context/` after meetings, decisions, or policy shifts.
- `meeting-sync` — Granola / Zoom transcript ingest into `01-background/transcripts/`.
