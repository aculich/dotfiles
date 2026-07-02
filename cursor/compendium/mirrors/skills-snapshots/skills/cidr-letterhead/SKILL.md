---
name: cidr-letterhead
description: Apply CiDR Lab official letterhead, Inter fonts, and brand styling to documents using the cidrlab/library templates (letterhead.docx, letterhead.md, cidr_brand.js, embed_fonts.py, pandoc/xelatex). Use when the user mentions CiDR letterhead, branded docx, a firm letter, a letter of support, a memo on letterhead, a qualifications letter, or /cidr-letterhead.
---

# cidr-letterhead

Apply CiDR Lab letterhead, Inter typography, masthead, and affiliation footer using the `cidrlab/library` template pipeline in this repo.

Skill lives in the library repo at `.cursor/skills/cidr-letterhead/`. Install globally: [INSTALL.md](INSTALL.md).

The canonical assets all live in this repo under `templates/`:

- `templates/letterhead/letterhead.docx` — built Word letterhead (Inter embedded)
- `templates/letterhead/letterhead.md` — pandoc/LaTeX letterhead source (PDF)
- `templates/letterhead/build_letterhead.js` — docx builder using `cidr_brand.js`
- `templates/letterhead/letterhead-preview.pdf` — rendered preview
- `templates/_build/cidr_brand.js` — shared masthead/footer/Inter helpers
- `templates/_build/embed_fonts.py` — finalize embedded Inter faces

## Quick start

Run scripts from the skill's `scripts/` directory (paths below assume `CIDR_LIBRARY` resolves to this repo — the scripts resolve it automatically):

```bash
# 1. Sync library + npm deps
scripts/ensure-library.sh

# 2a. Blank letterhead .docx (edit in Word)
scripts/regen-template-docx.sh letterhead

# 2b. Letter PDF from markdown (pandoc + xelatex)
scripts/build-letter-pdf.sh input.md output.pdf

# 2c. Finalize Inter on any docx-js output
scripts/embed-docx-fonts.sh output.docx
```

## Phase 0 — Resolve library

1. `CIDR_LIBRARY` resolves automatically to this repo (skill location, symlink-safe); set it only to override.
2. Run `scripts/ensure-library.sh` before builds.
3. For Node builders: `export NODE_PATH="$CIDR_LIBRARY/templates/node_modules"`.

## Phase 1 — Choose path

| Source | Output | Method |
|--------|--------|--------|
| New letter / memo | `.docx` | `scripts/regen-template-docx.sh letterhead` (or `memo`), then edit the `.docx` |
| Single letter needing a PDF | `.pdf` | Copy `templates/letterhead/letterhead.md`, fill the `{{...}}` placeholders, run `scripts/build-letter-pdf.sh` |
| Structured / multi-section doc | `.docx` | Write a `build_*.js` that requires `templates/_build/cidr_brand.js` (see [examples.md](examples.md)) |
| Existing arbitrary `.docx` | branded `.docx` | Paste content into `letterhead.docx` preserving masthead/footer, or rebuild via a `build_*.js` |
| Branded `.docx` preview | `.pdf` | `soffice --headless --convert-to pdf` (preserves the Inter docx layout) |

## Phase 2 — Always finalize docx

After any `.docx` built from `cidr_brand.js` / a `build_*.js`:

```bash
scripts/embed-docx-fonts.sh path/to/output.docx Inter
```

docx-js alone does not embed Inter correctly for recipients without the font installed. `embed_fonts.py` merges the four Inter faces and sets the embed switch.

## Phase 3 — Programmatic builder pattern

For a repeatable multi-section branded document, copy the shape of `templates/letterhead/build_letterhead.js`:

```javascript
const path = require("path");
const CIDR_LIBRARY = process.env.CIDR_LIBRARY || path.resolve(__dirname);
const B = require(path.join(CIDR_LIBRARY, "templates/_build/cidr_brand.js"));
const { t, link, P, redRule, masthead, makeDocument, write, C } = B;

const body = [];
body.push(masthead(), redRule(12, 220));
// ... content paragraphs ...
write(makeDocument(body, { title: "Document title" }), path.join(__dirname, "output.docx"));
```

Then:

```bash
export CIDR_LIBRARY NODE_PATH="$CIDR_LIBRARY/templates/node_modules"
node build_<name>.js
scripts/embed-docx-fonts.sh output.docx
```

## Phase 4 — PDF export from docx

```bash
soffice --headless --convert-to pdf --outdir "$(dirname "$DOCX")" "$DOCX"
```

Use for signed deliverables. Preserves the Inter docx layout.

## Guardrails

- Brand SSOT lives in this repo: `BRAND.md`, `brand/logos/cidr-logos-v14/`, `brand/fonts/inter/`.
- Use the repo masthead — the `.docx` builders call `masthead()` from `cidr_brand.js`; the PDF source uses the LaTeX header block in `letterhead.md`. Do not hand-roll the header.
- Two pipelines, two jobs: docx (`cidr_brand.js`) for editable/multi-section documents; pandoc + xelatex (`letterhead.md`) for a single-page letter PDF. Prefer LibreOffice to turn a finished docx into PDF rather than re-rendering long content through pandoc.
- Default letterhead signatory (from `build_letterhead.js`) is the CiDR Lab Director — override per document.
- Office: 1401 21st St, Suite R, Sacramento, CA 95811 · cidrlab.org.

## Scripts

| Script | Purpose |
|--------|---------|
| `ensure-library.sh` | Pull latest + `npm install` in `templates/` |
| `regen-template-docx.sh` | Rebuild blank `letterhead` / `memo` / `qualifications` `.docx` |
| `build-letter-pdf.sh` | Pandoc + xelatex PDF from a letterhead markdown source |
| `embed-docx-fonts.sh` | Run `embed_fonts.py` on a `.docx` |
| `install.sh` | Symlink skill → `~/.cursor/skills/cidr-letterhead` |
| `lib.sh` | Shared path resolution (sourced by the others) |

## Additional resources

- [examples.md](examples.md) — worked examples using the in-repo letterhead template
- [reference.md](reference.md) — brand tokens, template inventory, prerequisites
- [INSTALL.md](INSTALL.md) — global Cursor install
