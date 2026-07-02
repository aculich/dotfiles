// Synthetic example: programmatic branded .docx via cidr_brand.js.
// All content is fictional — this is an internal test/example for the
// cidr-letterhead skill (the docx pipeline, mirroring templates/*/build_*.js).
//
// Run:
//   export CIDR_LIBRARY NODE_PATH="$CIDR_LIBRARY/templates/node_modules"
//   node build_sample_memo.js [out.docx]
//   ../scripts/embed-docx-fonts.sh sample-memo.docx
const path = require("path");

const CIDR_LIBRARY = process.env.CIDR_LIBRARY || path.resolve(__dirname, "../../../..");
const {
  t, link, P, redRule, masthead, makeDocument, write, C,
  AlignmentType, HeadingLevel, Paragraph,
} = require(path.join(CIDR_LIBRARY, "templates/_build/cidr_brand.js"));

const field = (label, value) => P(
  [t(label, { bold: true, color: C.DARK }), t("\t" + value, { color: C.BLUE })],
  { spacing: { after: 60 }, tabStops: [{ type: "left", position: 1200 }] },
);

const body = [];
body.push(masthead(), redRule(12, 200));
body.push(new Paragraph({ heading: HeadingLevel.HEADING_1, children: [t("Memorandum (Synthetic Example)")] }));
body.push(field("To:", "Example Distribution List"));
body.push(field("From:", "Dr. Sam Example, Research Director — CiDR Lab"));
body.push(field("Date:", "January 15, 2026"));
body.push(field("Re:", "Sample branded memo for skill testing"));
body.push(redRule(4, 160, 40));

body.push(new Paragraph({ heading: HeadingLevel.HEADING_2, children: [t("Summary")] }));
body.push(P([t("This is a synthetic memo used to exercise the cidr-letterhead docx pipeline. All content is fictional.", { color: C.BLUE })], { alignment: AlignmentType.JUSTIFIED, spacing: { after: 160 } }));

body.push(new Paragraph({ heading: HeadingLevel.HEADING_2, children: [t("Details")] }));
body.push(P([t("It builds a Word document from cidr_brand.js — masthead, brand palette, Inter styles, and the affiliation footer — then embed_fonts.py finalizes the embedded Inter faces so it renders anywhere. Contact ", { color: C.BLUE }), link("mailto:sam@example.org", "sam@example.org"), t(" with questions.", { color: C.BLUE })], { alignment: AlignmentType.JUSTIFIED, spacing: { after: 160 } }));

body.push(new Paragraph({ heading: HeadingLevel.HEADING_2, children: [t("Next steps")] }));
body.push(P([t("Convert to PDF with LibreOffice for a shareable deliverable.", { color: C.BLUE })], { alignment: AlignmentType.JUSTIFIED, spacing: { after: 160 } }));

const out = process.argv[2] || path.join(__dirname, "sample-memo.docx");
write(makeDocument(body, { title: "CiDR Lab — Sample Memo (Synthetic)" }), out);
