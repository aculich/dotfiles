# Fireflies export — reference

## Endpoints

| Purpose | URL |
|--------|-----|
| GraphQL (Bearer API key) | `https://api.fireflies.ai/graphql` |
| MCP (remote) | `https://api.fireflies.ai/mcp` |

## Minimal transcript query

Use variables `transcriptId` = id from `app.fireflies.ai/view/<id>`.

```graphql
query OneTranscript($transcriptId: String!) {
  transcript(id: $transcriptId) {
    id
    title
    date
    duration
    host_email
    organizer_email
    participants
    meeting_link
    audio_url
    video_url
    speakers { id name }
    sentences {
      index
      speaker_id
      speaker_name
      text
      raw_text
      start_time
      end_time
    }
    summary {
      keywords
      action_items
      outline
      overview
      shorthand_bullet
      bullet_gist
      gist
      short_summary
      short_overview
      meeting_type
      topics_discussed
      transcript_chapters
    }
  }
}
```

`audio_url` / `video_url`: fetch as soon as possible; URLs rotate.

## UI "Download Meeting" matrix (for parity)

From the in-app dialog (transcript / summary / audio):

- **Transcript formats:** PDF, DOCX, SRT, CSV, JSON, MD — toggles: include timestamp, show speaker name, remove Fireflies branding.
- **Summary formats:** DOCX, PDF, JSON, MD — toggles: include timestamps, remove Fireflies branding.
- **Audio:** MP3.

This skill maps **data** to JSON/MD/CSV/SRT/MP3; PDF/DOCX are **optional** post-process from Markdown/JSON if the user needs pixel-parity with the app.

## cURL example (one-off)

```bash
FIREFLIES_API_KEY=...  # from Settings → Developer
TRANSCRIPT_ID=01KQ3MZ7J0108X2VQM8ZKW48RR

curl -sS -X POST 'https://api.fireflies.ai/graphql' \
  -H "Authorization: Bearer $FIREFLIES_API_KEY" \
  -H 'Content-Type: application/json' \
  --data "{\"query\": \"query T(\$id: String!){ transcript(id: \$id){ id title audio_url summary{ overview } sentences{ text speaker_name start_time } } }\", \"variables\": { \"id\": \"$TRANSCRIPT_ID\" } }"
```

## Links

- [Transcript query](https://docs.fireflies.ai/graphql-api/query/transcript)
- [MCP server blog (setup)](https://fireflies.ai/blog/fireflies-mcp-server/)
