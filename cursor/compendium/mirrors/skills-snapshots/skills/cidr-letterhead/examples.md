# cidr-letterhead — worked examples

All examples use the letterhead assets that ship in this repo under
`templates/`. Run script paths from the skill's `scripts/` directory.

---

## Example A — Blank letterhead .docx (edit in Word)

Use when you want the branded shell and will type the letter in Word.

```bash
scripts/regen-template-docx.sh letterhead
open templates/letterhead/letterhead.docx   # or edit in place / copy out first
```

`build_letterhead.js` lays down the masthead, red rule, Date / To / From / Re
fields, a body paragraph, a signature block, and the affiliation footer — then
`embed_fonts.py` finalizes the embedded Inter faces so it renders anywhere.

To keep a per-document copy instead of editing the template in place:

```bash
cp templates/letterhead/letterhead.docx /path/to/my-letter.docx
scripts/embed-docx-fonts.sh /path/to/my-letter.docx   # only if you rebuilt it
```

---

## Example B — Letter PDF from `letterhead.md`

Use for a single-page letter delivered as PDF. Start from the pandoc/LaTeX
source and fill its placeholders.

`templates/letterhead/letterhead.md` exposes:

`{{DATE}}`, `{{RECIPIENT NAME}}`, `{{RECIPIENT TITLE}}`, `{{RECIPIENT ORGANIZATION}}`,
`{{SENDER NAME}}`, `{{SENDER TITLE}}`, `{{SUBJECT}}`, `{{BODY TEXT}}`, `{{EMAIL}}`, `{{PHONE}}`.

```bash
cp templates/letterhead/letterhead.md /path/to/my-letter.md
# fill in the {{...}} placeholders in my-letter.md
scripts/build-letter-pdf.sh /path/to/my-letter.md /path/to/my-letter.pdf
```

The in-repo source references the logo with a path relative to
`templates/letterhead/`; `build-letter-pdf.sh` sets `--resource-path` so the
logo resolves whether you build in place or from a copy elsewhere. Portable
copies may instead use the `__LOGO_PATH__` placeholder, which the script
substitutes with the absolute logo path.

Preview reference: `templates/letterhead/letterhead-preview.pdf`.

---

## Example C — Programmatic multi-section .docx

Use for a repeatable document with several sections (letter + attachment,
qualifications, etc.). Model it on `templates/letterhead/build_letterhead.js`
and the sibling `templates/qualifications/build_qualifications.js`.

```javascript
// build_my_letter.js
const path = require("path");
const CIDR_LIBRARY = process.env.CIDR_LIBRARY || path.resolve(__dirname);
const { t, link, P, redRule, masthead, makeDocument, write, C, AlignmentType } =
  require(path.join(CIDR_LIBRARY, "templates/_build/cidr_brand.js"));

const body = [];
body.push(masthead(), redRule(12, 220));
body.push(P([t("Date:  ", { bold: true, color: C.DARK }), t("[Month DD, YYYY]", { color: C.BLUE })]));
body.push(P([t("[Body text.]", { color: C.BLUE })], { alignment: AlignmentType.JUSTIFIED, spacing: { after: 320 } }));
body.push(P([t("Sincerely,", { color: C.BLUE })], { spacing: { after: 480 } }));

write(makeDocument(body, { title: "CiDR Lab — Letter" }), path.join(__dirname, "my-letter.docx"));
```

```bash
export CIDR_LIBRARY NODE_PATH="$CIDR_LIBRARY/templates/node_modules"
node build_my_letter.js
scripts/embed-docx-fonts.sh my-letter.docx
```

---

## Sibling templates

The same pipeline drives the other document types in this repo — copy their
build scripts as starting points:

- `templates/memo/` — `build_memo.js` (To/From/Date/Re memo)
- `templates/qualifications/` — `build_qualifications.js` (quals, projects, references)
- `templates/invoice/` — `build_invoice_docx.js`
