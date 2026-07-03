---
name: limitless-takeout-update
description: Runs incremental Limitless takeout updates to fetch new lifelogs and chats since the last dump. Use when the user asks to update limitless data, run incremental takeout, sync limitless archive, or refresh limitless pendant data.
---

# Limitless Takeout Update

Run an incremental takeout from any Cursor workspace. Fetches only data newer than the last completed dump.

## Repo and scripts

All scripts live at a fixed path:

```
REPO=/Users/me/projects/limitless-quickstart/limitless-api-examples
```

Key files:
- `scripts/run_incremental_takeout.py` -- finds latest dump, computes since date, runs unified takeout
- `limitless_takeout_unified.py` -- the unified takeout engine
- `scripts/latest_takeout.py` -- discover latest dump
- `.env` -- contains `LIMITLESS_API_KEY` (loaded automatically by scripts)

## How to run an incremental update

Execute these shell commands (works from any workspace):

```bash
cd /Users/me/projects/limitless-quickstart/limitless-api-examples
export $(grep -v '^#' .env 2>/dev/null | grep -v '^$' | xargs)
python3 scripts/run_incremental_takeout.py
```

Optional flags: `--include-audio`, `--output-dir <path>`, `--no-chats`, `--dry-run`.

## After the run: provide a readout

After the command finishes, extract the output directory from the log line that says `Starting unified takeout to <path>`. Then read these files from that directory:

1. `manifest.json` -- get `export_date`, `export_duration_seconds`, and `options.since`
2. `lifelogs/summary.json` -- get `total_lifelogs`
3. `chats/summary.json` -- get `total_chats` (may not exist if `--no-chats`)
4. Check for audio files in `lifelogs/audio/` (count `.ogg` files)
5. Get total size: run `du -sh <output_dir>`

Present results as a table:

```
| Field      | Value                                   |
|------------|-----------------------------------------|
| Output     | <full path to new takeout directory>    |
| Since      | <since date from manifest options>      |
| Lifelogs   | <count>                                 |
| Chats      | <count>                                 |
| Audio      | <count> files (<size> MB) or "No"       |
| Duration   | <seconds> s                             |
| Total size | <size>                                  |
```

## Dry run

To preview what would happen without fetching:

```bash
cd /Users/me/projects/limitless-quickstart/limitless-api-examples
export $(grep -v '^#' .env 2>/dev/null | grep -v '^$' | xargs)
python3 scripts/run_incremental_takeout.py --dry-run
```

## Full takeout (if no previous dump exists)

If the incremental script reports "No takeout dumps found," run a full takeout instead:

```bash
cd /Users/me/projects/limitless-quickstart/limitless-api-examples
export $(grep -v '^#' .env 2>/dev/null | grep -v '^$' | xargs)
python3 limitless_takeout_unified.py --output-dir takeout --include-audio
```
