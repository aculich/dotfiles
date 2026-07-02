---
name: limitless-takeout-search
description: Searches local Limitless takeout dump files for lifelogs, chats, or text content by date range, keywords, or lifelog ID. Use when the user asks to search limitless data, find a conversation, look up a lifelog, query their pendant history, or find something they said/heard.
---

# Limitless Takeout Search

Search local takeout dump files from any Cursor workspace. Searches JSON files already downloaded -- does **not** call the live API.

## Data locations

Search these directories for takeout dumps (directories named `limitless_takeout_*` or `limitless_complete_takeout_*` or `data-export_*`):

1. `/Users/me/projects/limitless-quickstart/limitless-api-examples/takeout/`
2. `/Users/me/personal/takeout/limitless/`

The environment variable `TAKEOUT_OUTPUT_DIR` may also point to a custom location.

## Repo location

Helper scripts live at:

```
REPO=/Users/me/projects/limitless-quickstart/limitless-api-examples
```

## How to discover available dumps

```bash
cd /Users/me/projects/limitless-quickstart/limitless-api-examples
export $(grep -v '^#' .env 2>/dev/null | grep -v '^$' | xargs)
python3 scripts/latest_takeout.py
```

Or for a JSON summary with data ranges:

```bash
python3 scripts/compare_takeout_gaps.py --json
```

## File structure inside a dump

Each dump typically has:

```
limitless_takeout_YYYYMMDD_HHMMSS/
  manifest.json              # export metadata
  lifelogs/
    summary.json             # { total_lifelogs, lifelogs: [...], audio_stats }
    lifelogs_batch_1.json    # array of full lifelog objects
    lifelogs_batch_2.json    # (may have multiple batches)
  chats/
    summary.json             # { total_chats, ... }
    chats_batch_1.json       # array of chat objects
  account/
    account_info.json
```

### Lifelog fields (inside batch files)

Each lifelog object has these fields:

- `id` -- unique lifelog ID (string)
- `title` -- short title/summary of the conversation
- `startTime` -- ISO 8601 timestamp
- `endTime` -- ISO 8601 timestamp
- `markdown` -- full transcript in markdown format (main searchable text)
- `contents` -- structured array of content nodes
- `isStarred` -- boolean
- `updatedAt` -- ISO 8601 timestamp

The `summary.json` has a lighter version with only `id`, `title`, `startTime`, `endTime`.

## Search strategies

### By keyword (most common)

Use `rg` (ripgrep) for fast text search across batch files:

```bash
rg -l "search term" /Users/me/projects/limitless-quickstart/limitless-api-examples/takeout/limitless_takeout_*/lifelogs/lifelogs_batch_*.json
```

Then read matching files and parse the JSON to find the specific lifelog entries. Search the `title` and `markdown` fields.

For a more precise search, use Python:

```bash
cd /Users/me/projects/limitless-quickstart/limitless-api-examples
python3 -c "
import json, glob, sys
query = sys.argv[1].lower()
for batch_file in sorted(glob.glob('takeout/limitless_takeout_*/lifelogs/lifelogs_batch_*.json')):
    with open(batch_file) as f:
        for ll in json.load(f):
            if query in ll.get('title','').lower() or query in ll.get('markdown','').lower():
                print(f'{ll[\"startTime\"]}  {ll[\"id\"]}  {ll[\"title\"][:80]}')
" "search term"
```

### By date range

Filter lifelogs by `startTime`:

```bash
cd /Users/me/projects/limitless-quickstart/limitless-api-examples
python3 -c "
import json, glob, sys
start, end = sys.argv[1], sys.argv[2]
for batch_file in sorted(glob.glob('takeout/limitless_takeout_*/lifelogs/lifelogs_batch_*.json')):
    with open(batch_file) as f:
        for ll in json.load(f):
            t = ll.get('startTime','')
            if start <= t <= end:
                print(f'{t}  {ll[\"id\"]}  {ll[\"title\"][:80]}')
" "2026-02-01" "2026-02-28"
```

### By lifelog ID

Direct lookup:

```bash
cd /Users/me/projects/limitless-quickstart/limitless-api-examples
python3 -c "
import json, glob, sys
target = sys.argv[1]
for batch_file in sorted(glob.glob('takeout/limitless_takeout_*/lifelogs/lifelogs_batch_*.json')):
    with open(batch_file) as f:
        for ll in json.load(f):
            if ll.get('id') == target:
                print(json.dumps(ll, indent=2)[:2000])
                sys.exit(0)
print('Not found')
" "LIFELOG_ID_HERE"
```

### Searching the global personal archive too

Add the personal directory to the glob pattern:

```bash
rg -l "search term" /Users/me/personal/takeout/limitless/limitless_takeout_*/lifelogs/lifelogs_batch_*.json /Users/me/projects/limitless-quickstart/limitless-api-examples/takeout/limitless_takeout_*/lifelogs/lifelogs_batch_*.json
```

## Output format

When presenting search results, format each match as:

```
| Date       | Time  | ID                   | Title                                        |
|------------|-------|----------------------|----------------------------------------------|
| 2026-03-13 | 07:20 | q22dT42JJLQDKqhAQG7U | Inquiry about parking regulations in Berkeley |
```

If the user wants the full transcript, read the `markdown` field from the matching lifelog.

## Tips

- Always search the **latest/largest** dump first (it likely has the most data).
- The latest dump can be found with `scripts/latest_takeout.py`.
- If a dump uses `data-export_*` naming (official Limitless exports), look for JSON files under its subdirectories instead.
- For audio content, audio files are stored as `.ogg` in `lifelogs/audio/` within the dump.
