---
name: fireflies-meeting-export
description: >-
  Exports a Fireflies meeting through the Fireflies MCP or GraphQL API, then
  materializes transcript/summary/audio assets into a dated subfolder with
  manifest, index, and derived formats (MD, JSON, CSV, SRT). Use when the user
  wants Fireflies MCP, bulk meeting downloads, all export permutations, meeting
  asset archives, or transcript id from a fireflies.ai/view URL.
---

# Fireflies meeting export (MCP + local archive)

## When to use this skill

- User provides a Fireflies app URL like `https://app.fireflies.ai/view/<TRANSCRIPT_ID>` or asks to "download all formats" / "MCP" / "archive the meeting."
- **Goal:** Pull structured data via API/MCP, then **curate** files on disk (not 15 manual "Download" clicks in the app).

## What the API can vs cannot do (important)

- **MCP (beta)** exposes meeting intelligence (transcripts, metadata, speakers, summary) for connected tools—see the [Fireflies MCP announcement](https://fireflies.ai/blog/fireflies-mcp-server/). The exact **tool names** differ by client; the agent must **list MCP tool descriptors** and call the right fetch/search tools.
- The in-app **Download Meeting** dialog offers many **rendered** exports (e.g. PDF, DOCX, branded layouts). The **GraphQL API** instead returns **structured data** and **time-limited** `audio_url` / `video_url` links. "Remove Fireflies Branding" applies to their generated documents; **files built from API JSON/MD/CSV/SRT in this workflow are not watermarked** by default.
- To match **all** app permutations, derive parallel variants locally (e.g. transcript with and without speaker names, with and without millisecond timestamps) from `sentences` and the `summary` object. True **PDF/DOCX** are optional: generate via the user's preferred toolchain (Pandoc, `textutil`, etc.) from the produced Markdown/JSON, not as a direct Fireflies API call unless docs add an export endpoint.

## ChatGPT: global Fireflies connector (user completes in UI)

The user can register the hosted MCP in ChatGPT so the model can call Fireflies from there:

Go to ChatGPT Settings → Connectors → Create
Enter connector details:
Name: Fireflies MCP (or your preferred name)
MCP Server URL: https://api.fireflies.ai/mcp
Authentication: OAuth
Check "I trust this application"
Click Create
Complete the OAuth authentication when prompted

(Also documented on the [Fireflies MCP Server blog](https://fireflies.ai/blog/fireflies-mcp-server/).)

**Cursor / Claude Desktop:** add `npx mcp-remote https://api.fireflies.ai/mcp` with OAuth **or** pass `Authorization: Bearer <API_KEY>` in headers per the same post.

## Resolve the transcript id

- From a URL: `https://app.fireflies.ai/view/<ID>` → `<ID>` is the **transcript id** (example: `01KQ3MZ7J0108X2VQM8ZKW48RR`).

## Export workflow (agent)

1. **Connect:** Confirm Fireflies MCP is configured **or** use `FIREFLIES_API_KEY` with the GraphQL endpoint `https://api.fireflies.ai/graphql` (Bearer). Never print the key.
2. **Fetch:** Use MCP tools if present; else run a `transcript(id: "...")` query and request at minimum: `id` `title` `date` `duration` `speakers` `sentences { index speaker_name text raw_text start_time end_time }` `summary` `audio_url` `video_url` `participants` `meeting_link` `analytics` (optional). See [transcript query docs](https://docs.fireflies.ai/graphql-api/query/transcript).
3. **Download media immediately** when `audio_url` (or `video_url`) is present; links **expire** (~24h). Save under `assets/audio/`.
4. **Write raw bundle:** `raw/api-response.json` (or split `transcript.json` + `summary.json`) for reproducibility.
5. **Render "permutations"** the same way the UI conceptually does—by toggling:
   - **Transcript text:** with speaker labels on/off, timestamps on/off (and optional SRT/CSV rows from `start_time`/`end_time`). Write under `transcript/`.
   - **Summary blocks:** `overview` `action_items` `keywords` `outline` etc. from the `summary` object into `summary/`.
6. **Optional formats:** `transcript.srt` (from sentences), `utterances.csv` (one row per sentence with speaker, text, t0, t1), `meeting.md` (human index), `manifest.json` (machine index).
7. **Run the helper (optional):** if `raw/api-response.json` is saved, `python3 scripts/render_from_export.py` can expand MD/JSON/CSV/SRT. Adjust paths in the script if needed.
8. **Curation:** Fill `INDEX.md` (narrative: title, date, duration, list of files, what each is for) and ensure `manifest.json` lists `kind` + `relpath` for every asset.

## Output directory layout (default)

Root: user-chosen base, e.g. `fireflies-exports/<slug>_<short-id>/` where `slug` is a filesystem-safe title.

```text
<meeting-slug>_<id-prefix>/
  INDEX.md
  manifest.json
  raw/
    api-response.json
  assets/
    audio/    # meeting.mp3 when downloaded from audio_url
    video/    # if video_url used
  transcript/
    transcript--speakers+time.md
    transcript--speakers.md
    transcript--plain.md
    transcript.srt
    utterances.csv
  summary/
    summary.json
    summary.overview.md
  meta/
    participants.txt
```

## Categorization fields (manifest)

Use a small JSON schema: `meeting_id` `title` `date_iso` `source` `files[]: { "path" "type" "variant" "notes" }` `ingested_at_utc` `tool` (`mcp` or `graphql`).

## If MCP tools are unknown

1. List descriptor JSON under the MCP path for this workspace (e.g. `.../mcps/.../tools/`) and map names to actions.
2. If unavailable, fall back to **GraphQL** only; still produce the same folder structure.

## Additional detail

- GraphQL field reference and example queries: [reference.md](reference.md)
