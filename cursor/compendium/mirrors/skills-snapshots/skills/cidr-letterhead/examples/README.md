# cidr-letterhead — synthetic examples / internal tests

Fictional, self-contained inputs that exercise both pipelines end to end. All
names, dates, and details are synthetic. Build outputs land in `_out/`
(gitignored).

## Markdown → PDF (pandoc + xelatex)

`sample-letter.md` is a single-page letter with the LaTeX masthead, brand
palette, Inter typography (with font fallback), and affiliation footer. The
logo is referenced via the portable `__LOGO_PATH__` placeholder, which
`build-letter-pdf.sh` rewrites to the resolved absolute path.

```bash
../scripts/build-letter-pdf.sh sample-letter.md _out/sample-letter.pdf
```

## Programmatic .docx → PDF (cidr_brand.js)

`build_sample_memo.js` builds a branded memo `.docx` from `cidr_brand.js`
(masthead + palette + Inter styles + footer), then embed the Inter faces and
convert to PDF for a shareable deliverable.

```bash
node build_sample_memo.js _out/sample-memo.docx
../scripts/embed-docx-fonts.sh _out/sample-memo.docx        # finalize Inter
soffice --headless --convert-to pdf --outdir _out _out/sample-memo.docx
```

`node` needs `docx` resolvable — run `../scripts/ensure-library.sh` once (it
installs `templates/node_modules`), or set
`NODE_PATH="$CIDR_LIBRARY/templates/node_modules"`.
