---
name: change-world-editorial-desk
description: Editorial-desk layer above change-the-world critique. Classifies a draft, scores idea vs execution, names venue ceiling and rewrite gap, inventories unique already-critiqued sources, and can pick a scarce 5-piece slate. Use when the user asks publishability, magazine vs blog, which of N to publish, editorial desk, or venue fit.
---

# Change-the-world editorial desk

## When this applies

- The question is **editor**, not writing coach: what kind of piece is this, is the *idea* worth a scarce slot, and where does it belong.
- Sibling to **change-world-critique-quick**. Do **not** fold this into `change-world-system.txt`.
- Repo contains `change-the-world-gpt/scripts/editorial_desk.py`.

## What this is not

The existing critique asks whether *this draft* could change a reader's mind and how the author should strengthen it. The DSPy judge scores the **critique**, not the idea. This layer scores **idea (A)** separately from **execution (B)**, names **current venue vs ceiling**, and compares pieces for a 5-of-N slate.

## Repository root

Resolve `REPO` to the directory that contains `change-the-world-gpt/`. Prefer `REPO/.venv/bin/python`.

## Scores and venues

| Field | Meaning |
|-------|---------|
| `idea_score` (A) | Contribution if executed perfectly (1–7). Ignore prose. |
| `execution_score` (B) | Does this draft deliver that claim (1–7). |
| `stakes` | Who can act; what is at risk (1–7). |
| `novelty_of_claim` | Novelty of the *claim*, not the topic (1–7). |
| `tiredness` | High = recycled cluster default (1–7). |
| `slate_priority` | Computed: `A × stakes × (8 − tiredness)`. |

Venues: `personal-blog` | `trade-newsletter` | `linkedin` | `newspaper-oped` | `mid-tier-magazine` | `flagship-magazine` | `highbrow-journal`.

Slate rule: rank by `slate_priority`, then swap for **cluster diversity** and readers who can act. Do not ship five `ai-language-hollowing` essays. High-A + medium-B with a clear gap beats high-B + low-A. For already-published work, the question is amplify / would-we-have-picked, not republish.

## Commands

Single card (draft + existing critique):

```bash
DRAFT="/absolute/path/to/essay.md"
CRITIQUE="/absolute/path/to/essay.critique.TS.md"
REPO="/absolute/path/to/writing-quality"
OUT="${REPO}/change-the-world-gpt/editorial-desk/cards/$(basename "${DRAFT%.*}" | tr '[:upper:]' '[:lower:]').desk.md"
cd "$REPO" && OP_ACCOUNT=my.1password.com op run --env-file change-the-world-gpt/.env.op -- \
  "${REPO}/.venv/bin/python" change-the-world-gpt/scripts/editorial_desk.py \
  -i "$DRAFT" --critique "$CRITIQUE" -o "$OUT" \
  --provider openai --reasoning-effort high
```

Do **not** pass `--model` unless the user pins an id (OpenAI default `gpt-5.5`).

Inventory unique sources (Obsidian vault + this repo; latest change-world critique per draft):

```bash
cd "$REPO" && "${REPO}/.venv/bin/python" change-the-world-gpt/scripts/editorial_desk.py \
  --inventory -o "${REPO}/change-the-world-gpt/editorial-desk/inventory.json"
```

Batch cards from inventory:

```bash
cd "$REPO" && OP_ACCOUNT=my.1password.com op run --env-file change-the-world-gpt/.env.op -- \
  "${REPO}/.venv/bin/python" change-the-world-gpt/scripts/editorial_desk.py \
  --batch "${REPO}/change-the-world-gpt/editorial-desk/inventory.json" \
  --desk-dir "${REPO}/change-the-world-gpt/editorial-desk" \
  --provider openai --reasoning-effort high --workers 3
```

## Outputs

Under `change-the-world-gpt/editorial-desk/`:

| Path | Role |
|------|------|
| `cards/*.desk.md` | One YAML+prose card per unique source |
| `inventory.json` | Deduped draft/critique pairs |
| `batch_summary.json` | Batch run log |
| `EDITORIAL-DESK-MEMO.md` | Rubric, worked example, table, top-5 slate |

## Secrets

Same as the quick critique skill: `change-the-world-gpt/.env` or `op run --env-file change-the-world-gpt/.env.op`.
