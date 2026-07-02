---
name: change-world-critique-quick
description: Runs change-the-world-gpt critique_draft.py on a markdown draft and writes a timestamped sibling .md only. Use when the user wants a fast single-model critique, one-off draft feedback, or mentions critique_draft, quick critique, or sibling critique output without batch reports.
---

# Change-the-world critique (quick)

## When this applies

- One markdown (or text) draft, one provider/model, **one markdown file out**.
- Repo contains `change-the-world-gpt/scripts/critique_draft.py` (e.g. **writing-quality**).

## Repository root

Resolve `REPO` to the directory that contains `change-the-world-gpt/` (walk parents from the draft or cwd until that path exists). All script paths below are relative to `REPO`.

Prefer `REPO/.venv/bin/python` when it exists; else `python3`.

## `critique_draft.py` — inputs and flags

| Flag | Role |
|------|------|
| `-i` / `--input` | Path to draft file (required unless stdin). |
| `-o` / `--output` | Write critique here (optional; still prints to stdout). |
| `--provider` | `openai` (default), `anthropic`, `gemini`, `grok` (alias `rock`), `groq`, `ollama`, `mistral`, `openrouter`. |
| `--model` | Concrete model id; **omit** to use provider default (OpenAI **`gpt-5.5`**). |
| `-t` / `--temperature` | Optional float. Ignored with OpenAI when `--reasoning-effort` is set. |
| `--reasoning-effort` | OpenAI only: `none` \| `low` \| `medium` \| `high` \| `xhigh`. |
| `-p` / `--prompt-file` | System prompt file (default `change-the-world-gpt/prompts/change-world-system.txt`). |
| `--dotenv` | Explicit `.env` path (else loads `REPO/.env` and `REPO/change-the-world-gpt/.env`). |

**Outputs:** assistant markdown to stdout; if `-o` is set, same content to that file. Every critique is prefixed with **YAML frontmatter** (model/provider, source paths, `title`, `critique_of`, tags) unless `--no-emit-frontmatter`. **No** JSON sidecar, manifest, cost, or judge (use the `-full` skill for that).

## Output path (sibling + timestamp)

Given draft `DIR/STEM.ext` (any extension), use:

- Default: `OUT="${DIR}/${STEM}.critique.$(date +%Y%m%d-%H%M%S).md"`
- **Obsidian-style input** (vault `.obsidian` parent, `obsidian://` URI / vault path preamble, clipping YAML with `tags`/`source`/`created`, or path under `vaults/` / `Clippings/`):  
  `OUT="${DIR}/Critique - ${STEM}.critique.$(date +%Y%m%d-%H%M%S).md"`  
  (keeps the `.critique.*` segment; the `Critique - ` prefix makes the note title obvious in Obsidian file lists.)

**Frontmatter (all inputs):** YAML with `title: Critique - …`, `provider`, `model_id`, `source_draft_path`, `critique_of`, `tags`, plus source fields when present. **Obsidian inputs** also get `obsidian_uri`, `source_note_path`, and the `Critique - ` **filename** prefix. Disable YAML with `--no-emit-frontmatter`.

Bash example (robust stem = basename without final extension):

```bash
DRAFT="/absolute/path/to/essay.md"
REPO="/absolute/path/to/writing-quality"
TS=$(date +%Y%m%d-%H%M%S)
dir=$(cd "$(dirname "$DRAFT")" && pwd)
base=$(basename "$DRAFT")
stem="${base%.*}"
# Obsidian-aware path (script also prints this with --print-suggested-output):
OUT=$("${REPO}/.venv/bin/python" change-the-world-gpt/scripts/critique_draft.py -i "$DRAFT" --print-suggested-output 2>/dev/null || true)
if [ -z "$OUT" ]; then
  OUT="${dir}/${stem}.critique.${TS}.md"
fi
cd "$REPO" && "${REPO}/.venv/bin/python" change-the-world-gpt/scripts/critique_draft.py \
  -i "$DRAFT" -o "$OUT" --source-draft "$DRAFT" --critique-repo-root "$REPO" \
  --provider openai --reasoning-effort high
```

Do **not** pass `--model` unless the user pins a specific id; defaults come from `llm_providers.py` (`gpt-5.5` for OpenAI).

Quick check for suggested sibling path only:

```bash
cd "$REPO" && "${REPO}/.venv/bin/python" change-the-world-gpt/scripts/critique_draft.py -i "$DRAFT" --print-suggested-output
```

## Secrets

Use `change-the-world-gpt/.env` or `op run --env-file change-the-world-gpt/.env.op --` per project README. Provider keys are listed in `change-the-world-gpt/scripts/llm_providers.py` header.

## Full pipeline

For manifest, per-model `responses/*.json`, DSPy judge, cost/value reports, see sibling skill **`change-world-critique-quick-full`**.
