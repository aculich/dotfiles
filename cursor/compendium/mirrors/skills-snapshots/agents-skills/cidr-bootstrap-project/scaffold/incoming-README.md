# `incoming/` — unprocessed drops (gitignored)

This folder is the project's **inbox**. Anything dropped here (`.eml`, exports, screenshots, PDFs, CSVs, zip extracts) is **temporary** and **not** committed to git (see `.gitignore`).

## Workflow

1. **Drop:** save raw `.eml` files, attachments, or exports here.
2. **Process:**
   - Comms / email threads → parse, summarize, and file under `02-request-materials/communications/YYYY-MM-DD-NNN-short-description.md` per `communications/README.md`.
   - Source documents (statutes, PDFs, official forms) → move to `01-background/sources/{pdfs,web-snapshots,legal-statutes}/`.
   - Data files → move to `03-data-received/` (or to the gitignored ERN sibling clone if it belongs in analysis).
3. **Update:** add a row to `02-request-materials/communications/STATUS.md` and (if a decision was made) `.context/decisions.md`.
4. **Archive:** once processed, move the original `.eml` to `incoming/processed/YYYY-MM/` (still gitignored, but kept locally for provenance).

## Skills that read this folder

- **`context-engineering`** — synthesizes new email threads into `.context/` updates.
- **`meeting-sync`** — pairs with Granola / Zoom transcripts in `01-background/transcripts/`.
- **`cidr-bootstrap-project`** — used to seed this directory in the first place.

## Privacy

Do not commit anything from `incoming/`. Personal phone numbers, private scheduling URLs, and unredacted `.eml` headers stay local. Filed comms in `02-request-materials/communications/` should strip noisy quoted threads.
