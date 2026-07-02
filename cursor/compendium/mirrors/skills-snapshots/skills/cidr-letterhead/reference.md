# cidr-letterhead — reference

## Template inventory

| Template | `.docx` | Build script | PDF source |
|----------|---------|--------------|------------|
| Letterhead | `templates/letterhead/letterhead.docx` | `build_letterhead.js` | `letterhead.md` (pandoc + xelatex) |
| Memo | `templates/memo/memo.docx` | `build_memo.js` | `memo.md` |
| Qualifications | `templates/qualifications/qualifications-references.docx` | `build_qualifications.js` | `qualifications-references.md` |
| Invoice | `templates/invoice/invoice_template.docx` | `build_invoice_docx.js` | — |

Shared build modules:

- `templates/_build/cidr_brand.js` — masthead, footer, Inter, `makeDocument()`
- `templates/_build/embed_fonts.py` — merge Inter faces into docx

## Brand tokens (`cidr_brand.js`)

| Token | Hex | Use |
|-------|-----|-----|
| `C.RED` | `#F9322B` | Accent rules, links |
| `C.DARK` | `#19222C` | Headings, bold labels |
| `C.BLUE` | `#223754` | Body text |
| `C.STEEL` | `#8BA3BE` | Secondary text |
| `C.LIGHT` | `#E8EEF4` | Table shading |
| `C.HAIR` | `#D9E1EA` | Light borders |

Font: **Inter** (vendored in `brand/fonts/inter/`).

Logo (letterhead): `brand/logos/cidr-logos-v14/png-2x/wide-a-light.png`

Office address (masthead):

```
Collective Impact Data & Research Lab
1401 21st St, Suite R
Sacramento, CA 95811
cidrlab.org
```

Footer affiliation: UC Berkeley Eviction Research Network (`evictionresearch.net`).

## Prerequisites

| Tool | Required for |
|------|----------------|
| Node.js 18+ | `build_*.js`, `cidr_brand.js` |
| `npm install` in `templates/` | docx generation |
| Python 3 | `embed_fonts.py` |
| pandoc + xelatex | One-page letter PDFs |
| LibreOffice (`soffice`) | docx → PDF for deliverables |

Inter or Helvetica Neue on system helps xelatex PDF output; docx uses embedded Inter.

## Environment variables

| Variable | Purpose |
|----------|---------|
| `CIDR_LIBRARY` | Override the library checkout path; auto-resolves to this repo otherwise |
| `NODE_PATH` | Set to `$CIDR_LIBRARY/templates/node_modules` for standalone builders |

## Logo path in pandoc markdown

The in-repo `templates/letterhead/letterhead.md` references the logo relative to
its own directory:

```latex
\includegraphics[width=2.8in]{../../brand/logos/cidr-logos-v14/png-2x/wide-a-light.png}
```

`build-letter-pdf.sh` sets `--resource-path` so this resolves when building in
place or from a copy elsewhere.

For a fully portable copy, use the placeholder instead:

```latex
\includegraphics[width=2.8in]{__LOGO_PATH__}
```

`build-letter-pdf.sh` substitutes it with the logo path from the resolved
library checkout.
