---
name: wip-harvest
description: Harvest high-signal WIP markdown from one or more project roots, filter READMEs/vendored/auto-generated noise, rank by path + filename-semantic-token + content + (optional) LLM signals, preview, then stage into examples/incoming/ and hand off to ingest_incoming.py.
---

# wip-harvest

Use when the user says **`wip-harvest`**, **`/wip-harvest`**, or asks to "harvest WIP from <project>" / "find high-value writing in <repo> for audio". This is the front half of the EchoTrails WIP audiocast pipeline. Do NOT confuse with `baloney-scan`, which is a separate ecosystem-research workflow.

## Scope (and what is NOT this skill)

- IN scope: walk `~/projects/*/`, filter, rank, preview, stage to `examples/incoming/<slug>-<stamp>/`, call `bin/ingest_incoming.py`.
- OUT of scope: producing audio (that's `wip-distill`), publishing to EchoTrails (that's `wip-publish`), anything related to `audio.thebaloney.ai`, Cloudflare R2, `skills/baloney-scan/`, or `bin/generate_rss_feed.py`.

## Prerequisites

- **Python** with `pyyaml` available. If missing: `pip install pyyaml`.
- **git** on PATH (for `recent` scan mode).
- **Config**: [config/wip_harvest.yaml](../../config/wip_harvest.yaml) — curated token lists, exclusion rules, author-owned-repo gate.
- **Optional**: `OPENAI_API_KEY` loaded via `op run --env-file .env.op --` when using `--llm-signal`.

## Output file contract

| Artifact | Path |
|----------|------|
| Candidates ledger (every file considered, all scores, reasons, route) | `tmp/wip-harvest-<UTCstamp>/candidates.json` |
| Skipped-roots log | `tmp/wip-harvest-<UTCstamp>/skipped-roots.json` |
| Staged files | `examples/incoming/<slug>-<UTCstamp>/*.md` (subpaths flattened to `dir__subdir__name.md`) |
| Incoming manifest | `examples/incoming/<slug>-<UTCstamp>/MANIFEST.md` |
| Route tags (used by `wip-distill`) | `examples/incoming/<slug>-<UTCstamp>/wip_routes.json` |

All of `tmp/wip-harvest-*` is gitignored.

## Ordered steps

1. **Pick roots** — default single root is whichever project the user named. Multi-root runs are OK: pass `--root` multiple times. Each root becomes its own `<slug>-<stamp>` incoming directory.
2. **Dry-run preview first** — for unfamiliar repos, always run `--dry-run` first so the user sees the candidates.json without any filesystem writes into `examples/incoming/`.
3. **Invoke**:
    ```bash
    python bin/harvest_wip.py --root ~/projects/<project> [--scan-mode auto] [--since YYYY-MM-DD] \
        [--top N] [--pick REGEX] [--exclude REGEX] [--llm-signal] [--dry-run|--yes]
    ```
4. **Review the preview** — the script pauses before staging unless `--yes`. The preview prints per-candidate score, route, and the chain of reasons. Use `--pick` / `--exclude` to iterate without re-scanning an unfamiliar repo.
5. **Stage** — confirm (or pass `--yes`) to copy files into `examples/incoming/<slug>-<stamp>/` and write `MANIFEST.md` + `wip_routes.json`.
6. **Hand off to ingest** — by default the script auto-runs `bin/ingest_incoming.py <slug>-<stamp>` which registers entries in [examples/curated/source_manifest.json](../../examples/curated/source_manifest.json). Pass `--no-ingest` to skip.

## Scan modes (`--scan-mode`)

| Mode | When it runs | Notes |
|------|--------------|-------|
| `auto` | default | starts `recent`; falls back to `archive` if fewer than `min_recent_results` (3) files surface |
| `recent` | hot repos (e.g. `peeq-crb-nexus`) | git-log since `--since`, author-filtered |
| `archive` | cold repos (e.g. `ai-veracity-chains`) | ignores mtime, relies on filename + content heuristics |
| `full` | diagnostics | no timestamp filter, no score threshold, return everything ranked |
| `mtime-walk` | non-git fallback | `os.walk` when git-log unavailable |

## Scoring layers (higher = more likely to be read aloud)

1. **Path signals** — +10 for known high-signal paths (`meeting-notes-granola/`, `application/`, `narrative/`, `critiques/`, `.context/`, etc.), +5 for ISO-date-prefixed filenames, soft mtime bumps (+3 within 7d, +1 within 30d), -5 for dirs that sit next to `package.json`/`pyproject.toml`/`Cargo.toml`.
2. **Filename semantic tokens** — +6 per matched positive token (capped at +12): manifesto/narrative/story/first-person/vision/strategy/pitch/execsummary/deck/directors-cut/etc. -6 per negative token: codebase-analysis/feature-testing/final-status/diagrams/test-results/etc. Neutral tokens (architecture/techstack/platform/slides) keep the file but route it to `essence`, not verbatim.
3. **Derivative-file collapse** — if `FUTURE-NARRATIVE.md` + `FUTURE-NARRATIVE-SUMY-luhn.md` both exist in the same dir, drop the derivative.
4. **Content signals** (top 100 candidates only, bounded cost) — +4 first-person pronouns in head, +3 italicized tagline, +3 narrative-length paragraph cadence, -4 heavy code-fence/table density, -6 auto-gen phrase signatures.
5. **Optional LLM classifier** — with `--llm-signal`, ambiguous files (score within `[min_score, min_score+5]`, cap 30) are sent to `gpt-4.1-mini` for `classification + listen_value 0-10`. Delta = `listen_value - 5` is added to the score.

## Route tagging (consumed by `wip-distill`)

Every kept candidate writes a `route` into `wip_routes.json`:

| Route | Distill mode | Trigger |
|-------|-------------|---------|
| `narrative` | verbatim L1 | narrative / story / manifesto / first-person tokens |
| `strategic` | verbatim L1 | vision / strategy / positioning / future tokens |
| `technical-doc` | essence | architecture / platform / techstack / design / large (> 50k chars) |
| `critique-fold-member` | critique-fold | ≥3 sibling files matching `<stem>__<vendor>__<model>.md` |
| `auto-generated-report` | skipped | "generated by", test-results signatures, heavy negative tokens |

## Nested-git-repo handling

A nested `.git` directory is walked into when:

- It has no remote URL configured (local author-owned sub-project), OR
- Its `user.email` matches the outer repo's `user.email`

Otherwise it is pruned (external clone). This is how `visual-veritas/docs/FIRST-PERSON-STORY.md` inside `~/projects/ai-veracity-chains/visual-veritas/` (local sub-repo, no remote) is still harvested, while `deep-libguide/ai-cookbook__perplexityai/` (actual external clone) is skipped.

## Messy-repo tuning cheat sheet

| Symptom | Likely fix |
|---------|------------|
| Thousands of Python site-package `.md` files in candidates | Ensure `.venv`, `venv`, `site-packages`, `.dist-info` are in `exclude_dir_names` / `exclude_dir_regex` |
| Cursor chat history polluting results | `.specstory` must be in `exclude_dir_names` |
| External cloned repos surviving | Add to `exclude_dir_regex` (`org__repo` pattern) or add an `upstream/` ancestor dir |
| High-signal all-caps file (`VISION.md`) not ranking | Confirm it's picked up by a positive token list (vision/strategy/manifesto/etc.) — if not, add to `positive_tokens_*` in [config/wip_harvest.yaml](../../config/wip_harvest.yaml) |
| Noise files ranking too high because they happen to mention "narrative" in filename | Add a more specific negative token; or use `--exclude REGEX` on the CLI for a one-off |

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success (or dry-run finished cleanly, or user declined staging) |
| 1 | Ingest handoff (`bin/ingest_incoming.py`) failed |
| 2 | Missing dependency (pyyaml) |

## Optional: local Cursor skills picker

Symlink `skills/wip-harvest` into `~/.cursor/skills/wip-harvest/` on your machine (not scripted) to surface this skill in Cursor's picker.
