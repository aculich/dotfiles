---
name: report-reforge
description: >-
  Inbox-to-county report reforge: discover vendor PDFs, decompose to CSVs,
  reconstruct A-side Quarto, reproduce B-side from public data, A/B compare with
  a seven-category discrepancy taxonomy, port geography, scale Tier 1–3, and
  routinize. Use for enrollment studies, facility/capacity packets, or
  analogous hospitals/public-health market studies. Triggers: report reforge,
  A/B reconstruction, NESDEC/NHSAA cycle, upstream CCD/CSR, Tier 1/2/3
  landscape, methodology pipeline, vendor PDF → Quarto.
---

# Report Reforge — operational skill

Canonical long-form: when in `cidr-zeal`, read `docs/methodology-report-reforge.md`.  
Reference implementation: `cidr-zeal` (Yarmouth → Hampstead → RCSD/SMC).

## When to use

- User drops a consultant/vendor PDF (enrollment, facilities, market study) and wants a reproducible pipeline.
- Need A-side (faithful) + B-side (public) + discrepancy narrative.
- Porting a template to a new geography or domain (schools → hospitals).

## Phase checklist (do in order)

1. **Discover** — Gmail/`gog-as` attachments → `incoming/`; STATUS hub; copyright note.
2. **Research** — parallel search packs; methodology keywords.
3. **Decompose** — extract slug (`text/structure/tables/images`); Gemini page cards if needed; CSV + `validation.json`.
4. **A-side** — faithful Quarto; internal-use banner if exclusive copyright.
5. **B-side** — source matrix; fetch/clean/CSR; sha256 manifests; acquisition note.
6. **Compare** — taxonomy codes; JSON + Quarto + narrative; link STATUS/memo.
7. **Port** — validate IDs via authoritative crosswalk; swap state sources.
8. **Scale** — roster → Wave A/B/C → Tier 1/2/3 → Have/Partial/Missing matrix → hotspots.
9. **Hygiene** — bulky raw gitignored; sliced tables tracked; commit only if asked.
10. **Routinize** — update methodology doc + this skill if the loop learned something new.

## Vocabulary

| Term | Meaning |
|------|---------|
| A-side / B-side | Extract Quarto / public upstream Quarto |
| Tier 1/2/3 | LEA → city landscape → county atlas |
| Wave A/B/C | Easy data-grab stages |
| Have/Partial/Missing | Factor fill status |
| Discrepancy codes | ACCESS_GAP, DEFINITION, VINTAGE_CUTOFF, IMPUTATION_OR_ESTIMATE, MODEL_CHOICE, TRANSCRIPTION_OR_ALIGN, MEANINGFUL_UNEXPLAINED |

## Command spine (education)

```bash
uv run python tools/jeff-doc-extract/extract_hampstead_tables.py
uv run python tools/upstream-hampstead/fetch.py
uv run python tools/upstream-hampstead/clean.py
uv run python tools/upstream-hampstead/csr_multi.py
uv run python tools/upstream-hampstead/compare.py
# portable multi-model:
uv run python tools/upstream-hampstead/csr_multi.py --tables incoming/upstream/<lea>/tables
```

## Critical lessons

- **Validate LEAID** with `state_leaid` crosswalk before fetch (wrong LEA silently poisons B-side).
- **Births:** CA ZIP often open; ME/NH town often ACCESS_GAP — document, don’t invent.
- **Facility capacity:** usually district_share ACCESS_GAP; keep schema for product depth.
- **Multi-model panel** (`csr_multi`) beats a false single-point forecast for board uncertainty.
- **Never delete** large extracts without explicit user permission.
- **Commits only when requested.**

## Hospitals transfer (quick)

| Schools | Hospitals |
|---------|-----------|
| CCD/CDE enrollment | HCAI/AHA utilization |
| Vital births | CDC WONDER / HCUP / state natality |
| BPS permits / generation rates | Demand drivers / insured population |
| Room capacity × loading | Licensed beds / OR minutes |
| NESDEC/NHSAA packet | CON / CHNA / consultant market study |

## Done when

Validated CSVs · A and/or B Quarto renders · compare+acquisition notes · STATUS linked · copyright respected.
