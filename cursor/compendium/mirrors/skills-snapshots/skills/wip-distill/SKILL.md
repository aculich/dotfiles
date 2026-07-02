---
name: wip-distill
description: Dispatch curated WIP markdown files through per-file distill modes (verbatim / essence / critique-fold) based on route tags from wip-harvest or heuristic fallback, producing mp3s under examples/audio_output/levels/ for the EchoTrails publish step.
---

# wip-distill

Use when the user says **`wip-distill`**, **`/wip-distill`**, or asks to "produce audio for <source-dir>". Middle stage of the EchoTrails WIP audiocast pipeline. Input is a ready curated `<slug>-<stamp>/` directory; output is level-segmented mp3s ready for `wip-publish`.

## Scope (and what is NOT this skill)

- IN scope: pick distill mode per file, call the right producer script, record output paths.
- OUT of scope: harvesting / selecting (that's `wip-harvest`), publishing to EchoTrails (`wip-publish`), anything Baloney-related.

## Prerequisites

- Curated source exists at `examples/curated/<slug>-<stamp>/*.md` (after `wip-harvest` ran and handed off to `bin/ingest_incoming.py`).
- **google-genai + python-dotenv** (already in `requirements.txt`). Gemini 3.1 Flash TTS is the default backend.
- **ffmpeg** for PCM→MP3 encode and concat.
- **Cached API keys in `.env`** — populate once via `bash bin/refresh_env.sh` (one Touch ID). Required keys: `GEMINI_API_KEY`, `OPENAI_API_KEY` (for essence / fold LLM calls).

## TTS defaults (see [config/echotrails.yaml](../../config/echotrails.yaml))

| Setting | Default |
|---|---|
| Backend | `gemini` (Gemini 3.1 Flash TTS Preview) |
| Voice | `Charon` (male, deep/warm, American) |
| Model | `gemini-3.1-flash-tts-preview` |
| Prompt style | "Warm, measured delivery. Clear American English." |

Override per-invocation: `--tts-backend edge --voice en-GB-RyanNeural` for the legacy free path, or `--voice Kore` / `--voice Sulafat` / `--voice Puck` for other Gemini voices.

## File contract

| Mode | Output location | Producer |
|------|----------------|----------|
| `verbatim` | `examples/audio_output/levels/L1_instant/<source-dir>/<stem>_L1_<Voice>_<backend-tag>.mp3` | [bin/publish_with_levels.py](../../bin/publish_with_levels.py) `--level L1` |
| `essence` | `examples/audio_output/levels/essence/<source-dir>/<stem>_essence_<Voice>_<backend-tag>.mp3` + `<stem>_essence.md` + `<stem>_essence_meta.json` | [bin/generate_essence.py](../../bin/generate_essence.py) `--generate-audio` |
| `fold` | `examples/audio_output/levels/critique_fold/<source-dir>/<safe_stem>_critique_fold_<Voice>_<backend-tag>.mp3` + sidecar md + meta | [bin/fold_critiques.py](../../bin/fold_critiques.py) `--generate-audio` |

`<backend-tag>` is `gemini-3.1-flash-tts` for Gemini outputs, `edge-tts` for legacy. This lets old and new files coexist without overwriting each other. Each producer writes its own sidecar metadata. `wip-publish` later promotes these into `wip/<slug-uuid8>/` on GCS.

## Mode-selection rules (highest priority first)

1. **CLI override**: `--file FOO.md --mode essence` forces one file.
2. **Explicit override file**: `examples/curated/<source-dir>/wip_modes.json` — map of `{"filename.md": "verbatim|essence|fold|skip"}`.
3. **Harvest route tag**: `examples/incoming/<source-dir>/wip_routes.json` (written by `bin/harvest_wip.py`). Route mapping:
    - `narrative` -> verbatim
    - `strategic` -> verbatim
    - `technical-doc` -> essence
    - `critique-fold-member` -> fold
    - `auto-generated-report` -> skip
4. **Heuristic fallback** (when no tag exists):
    - Filename matches `<stem>__<vendor>__<model>.md` AND >= 3 such siblings share the stem → fold
    - File size > 40,000 bytes → essence
    - Otherwise → verbatim

## Ordered steps

1. **Confirm curated dir exists**:
    ```bash
    ls examples/curated/<source-dir>/
    ```
2. **Dry-run first** to see the dispatch plan:
    ```bash
    python bin/wip_distill.py --source-dir <source-dir> --dry-run
    ```
    Output shows `verbatim: N`, `essence: N`, `fold: N file(s) in M group(s)`, `skipped: N`, with each file listed.
3. **Run for real** (keys are loaded automatically from `.env`):
    ```bash
    python bin/wip_distill.py --source-dir <source-dir>
    ```
    If `.env` is stale or missing keys, run `bash bin/refresh_env.sh` once (single Touch ID). No per-command `op run` needed.
4. **Audio lands** under `examples/audio_output/levels/{L1_instant,essence,critique_fold}/<source-dir>/`.

## Overriding a single file

```bash
python bin/wip_distill.py --source-dir <source-dir> \
    --file visual-veritas__docs__FIRST-PERSON-STORY.md --mode verbatim
```

Or create `examples/curated/<source-dir>/wip_modes.json`:

```json
{
  "visual-veritas__docs__FIRST-PERSON-STORY.md": "verbatim",
  "visual-veritas__docs__ARCHITECTURE.md": "essence",
  "application__video__critiques__critiques__3min-video-script__openai__gpt-5.4.md": "fold"
}
```

## Re-running / regenerating

- **Regenerate a single file in essence mode**:
    ```bash
    python bin/wip_distill.py --source-dir <source-dir> --only-mode essence --file FOO.md
    ```
- **Regenerate a critique-fold group**: delete the `<safe_stem>_critique_fold*` sidecars from `examples/audio_output/levels/critique_fold/<source-dir>/` and re-run; fold_critiques.py always overwrites.
- **Switch modes after the fact**: edit `wip_modes.json` and re-run `wip-distill --source-dir <source-dir>`. Existing L1 files are overwritten by `publish_with_levels.py`; essence and fold outputs rewrite in place.

## Expected end-state for the astera critiques example

Curated dir:
```
examples/curated/astera-envisioning-20260419T.../
  application__video__3min-video-script.md              -> verbatim
  application__narrative__astera-vision.md              -> verbatim (tokens: vision)
  application__vision__VISION.md                        -> verbatim
  application__video__critiques__critiques__3min-video-script__openai__gpt-5.4.md       -> fold
  application__video__critiques__critiques__3min-video-script__anthropic__claude-*.md   -> fold
  application__video__critiques__critiques__3min-video-script__groq__llama-*.md         -> fold
  ... (>= 3 siblings, detected as one fold group)
```

After `wip-distill`:
```
examples/audio_output/levels/
  L1_instant/astera-envisioning-20260419T.../
    application__video__3min-video-script_L1_Ryan_edge-tts.mp3
    application__narrative__astera-vision_L1_Ryan_edge-tts.mp3
    application__vision__VISION_L1_Ryan_edge-tts.mp3
  critique_fold/astera-envisioning-20260419T.../
    3min-video-script_critique_fold.md
    3min-video-script_critique_fold_meta.json
    3min-video-script_critique_fold_Ryan_edge-tts.mp3
```

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | All dispatched modes succeeded |
| non-zero | At least one dispatched mode failed; stdout shows which |

## Optional: local Cursor skills picker

Symlink `skills/wip-distill` into `~/.cursor/skills/wip-distill/` on your machine.
