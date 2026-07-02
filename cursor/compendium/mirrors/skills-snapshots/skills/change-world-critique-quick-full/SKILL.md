---
name: change-world-critique-quick-full
description: Runs the full change-the-world-gpt single-draft pipeline (batch one post, judge, comparison, cost, value) into a timestamped sibling directory with critiques/, responses/*.json, and reports. Use when the user wants structured API metadata, evaluation_report, COMPARISON/COST/VALUE, or affix -full / full critique output for one markdown draft.
---

# Change-the-world critique (full single draft)

## When this applies

- One draft file; user wants **everything** the tooling can emit for that draft: multi-model critiques, raw JSON sidecars, manifest, DSPy judge scores, comparison and cost/value reports.
- Same repo layout as the quick skill (`REPO/change-the-world-gpt/`).

## What gets produced (single run directory)

Create one sibling folder: `DIR/STEM.critique-run.YYYYMMDD-HHMMSS/` (same `DIR`/`STEM` as the quick skill).

Inside it (manifest v2 layout):

| Path | From script |
|------|-------------|
| `run_manifest.json` | `critique_batch.py` |
| `critiques/*.md` | batch |
| `responses/*.json` | batch (request + API `response`; omit with `--no-response-json`) |
| `evaluation_report.json` | `critique_evaluate.py` |
| `COMPARISON.md` | `critique_compare_report.py` |
| `COST_REPORT.md`, `cost_summary.json` | `critique_cost_report.py` |
| `VALUE_REPORT.md`, `value_summary.json` | `critique_value_report.py` |

**Not produced by single-draft flow:** `critique_draft.py` alone does not write JSON; the batch path does. Crosswalk / strip utilities are separate CLIs.

## `critique_draft.py` parameters (reference)

Same flags as the quick skill: `-i`, `-o`, `--provider`, `--model`, `-t`, `--reasoning-effort`, `-p`, `--dotenv`. This full workflow uses **batch + downstream scripts** instead of `critique_draft.py`, unless you only need one model—in which case you could use `critique_draft` plus manual steps; prefer batch for parity with manifest and `responses/`.

## Workflow (run from `REPO`)

1. Resolve `REPO` (parent tree contains `change-the-world-gpt/`).
2. `PY="${REPO}/.venv/bin/python"` or `python3`.
3. Set paths:

```bash
DRAFT="/absolute/path/to/essay.md"   # must be readable
TS=$(date +%Y%m%d-%H%M%S)
dir=$(cd "$(dirname "$DRAFT")" && pwd)
base=$(basename "$DRAFT")
stem="${base%.*}"
OUT_DIR="${dir}/${stem}.critique-run.${TS}"
mkdir -p "$OUT_DIR"
```

**Frontmatter (all inputs):** every `critiques/*.md` file starts with YAML (model, provider, source paths, `title`, `critique_of`, tags). **Obsidian-style drafts** also use filenames `critiques/Critique - STEM__provider__model.md` and may include `obsidian_uri` / `source_note_path`. The run directory stays `STEM.critique-run.TS/`.

4. **Batch** (one file; adjust preset/extras as needed):

```bash
cd "$REPO" && "$PY" change-the-world-gpt/scripts/critique_batch.py \
  --preset compare \
  --no-ollama --skip-missing-keys \
  --post "$DRAFT" \
  -o "$OUT_DIR"
```

Use `--preset none -M openai:gpt-5.5` for a single OpenAI row (latest default). Add `--with-openrouter` only if the user wants OpenRouter in compare/all.

5. **Judge** (`JUDGE` default `openai/gpt-5.5`):

```bash
cd "$REPO" && "$PY" change-the-world-gpt/scripts/critique_evaluate.py \
  -m "$OUT_DIR/run_manifest.json" \
  --judge "${JUDGE:-openai/gpt-5.5}"
```

`--preset compare` already includes **`gpt-5.5`** and **`gpt-5.4`** OpenAI rows; omit extra `-M` unless narrowing the matrix.

6. **Reports:**

```bash
MAN="$OUT_DIR/run_manifest.json"
EV="$OUT_DIR/evaluation_report.json"
cd "$REPO" && "$PY" change-the-world-gpt/scripts/critique_compare_report.py -e "$EV" -m "$MAN" -o "$OUT_DIR/COMPARISON.md"
cd "$REPO" && "$PY" change-the-world-gpt/scripts/critique_cost_report.py \
  --manifest "$MAN" --evaluation-report "$EV" \
  -o "$OUT_DIR/COST_REPORT.md" --json-out "$OUT_DIR/cost_summary.json"
cd "$REPO" && "$PY" change-the-world-gpt/scripts/critique_value_report.py \
  --manifest "$MAN" --evaluation "$EV" \
  -o "$OUT_DIR/VALUE_REPORT.md" --json-out "$OUT_DIR/value_summary.json"
```

Alternatively from `REPO`: `make -C change-the-world-gpt pipeline OUT_DIR="$OUT_DIR_REL"` where `OUT_DIR_REL` is `OUT_DIR` **relative to** `change-the-world-gpt/` (e.g. if `OUT_DIR` is under `change-the-world-gpt/critique-runs/foo`, pass that relative path). If the sibling folder **must** live next to the draft **outside** `change-the-world-gpt/`, use the explicit Python invocations above with an **absolute** `-o` so batch writes directly to `OUT_DIR`.

## Makefile variant (outputs under `change-the-world-gpt/`)

If sibling-next-to-draft is not required:

```bash
make -C change-the-world-gpt pipeline \
  INPUTS_LIST=inputs/your_one_post.json \
  BATCH_EXTRA='--no-ollama --skip-missing-keys'
```

Use a one-entry JSON list (see `change-the-world-gpt/inputs/many_shades_placeholder.json`) pointing at the draft path **relative to `REPO`**.

## Secrets

Same as quick skill: `change-the-world-gpt/.env` or `op run` with `.env.op`.

## Quick vs full

| | Quick skill | This skill |
|--|-------------|------------|
| Output | One sibling `*.critique.TS.md` (Obsidian: `Critique - *.critique.TS.md` + YAML FM) | One sibling directory `*.critique-run.TS/` with full tree |
| Entry CLI | `critique_draft.py` | `critique_batch.py` + evaluate + reports |
| JSON / costs | No | Yes |
| YAML frontmatter | Default on all outputs (`critique_draft.py`) | Default on all `critiques/*.md` (`critique_batch.py`) |
| Obsidian filename | `Critique - *.critique.TS.md` when detected | `Critique - STEM__provider__model.md` when detected |

See **`change-world-critique-quick`** for the minimal `critique_draft.py` command.
