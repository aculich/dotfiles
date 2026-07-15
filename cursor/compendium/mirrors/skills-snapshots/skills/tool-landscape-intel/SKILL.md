---
name: tool-landscape-intel
description: Orchestrates multi-channel landscape intelligence for tracked tools — Discord announcements, YouTube transcripts/comments, web traction (YC/HN/blogs), plus optional git upstream digest. Use when the user asks for landscape intel, market traction, Discord announcements, YC chatter, YouTube demos, or how a tool appears in startup/investment discourse. Generalized via profile YAML; rowboat is the default profile in rowboat-quickstart.
---

# Tool Landscape Intel

Multi-channel monitoring: **git + Discord + YouTube + web traction**, synthesized into landscape digests.

## When to use

- "Landscape intel", "traction", "how is Rowboat appearing", "YC chatter"
- Discord `#announcements` delta since last check
- YouTube demo transcripts and comment sentiment
- HN/blog/funding signals via parallel-cli
- Combined view before prioritizing fork work

## Config (rowboat-quickstart workspace)

| Key | Path |
|-----|------|
| Profile | `.devdocs/landscape-profiles/rowboat.yaml` |
| Orchestrator | `scripts/landscape-intel.sh` |
| Git digest (child) | `scripts/upstream-digest.sh` + skill `rowboat-upstream-digest` |
| Output | `rowboat__aculich/.devdocs/digests/LANDSCAPE_INTEL_YYYY-MM-DD.md` |
| Discord manual | `rowboat__aculich/.devdocs/landscape/sources/discord/manual/` |
| YouTube sources | `rowboat__aculich/.devdocs/landscape/sources/youtube/` |
| Web JSON | `rowboat__aculich/.devdocs/landscape/parallel/search-traction-*.json` |
| MCP template | `.devdocs/MCP_DISCORD.template.json` |

**Generalization:** Add `.devdocs/landscape-profiles/<tool>.yaml`; run `--profile <tool>`.

## Quick start

From **rowboat-quickstart** root:

```bash
# Full pass (manual Discord + web + youtube + git report, no sync)
./scripts/landscape-intel.sh --profile rowboat --no-git \
  --discord-method file --update-state

# Include git upstream digest
./scripts/landscape-intel.sh --profile rowboat --git --update-state

# Discord via Desktop (opencli)
./scripts/landscape-intel.sh --profile rowboat --discord-method opencli
```

Sub-scripts (individual channels):

```bash
./scripts/landscape-discord-ingest.sh --profile rowboat --method file
./scripts/landscape-youtube-ingest.sh --profile rowboat
./scripts/landscape-web-search.sh --profile rowboat
```

## Eight-phase workflow

```
Landscape intel:
- [ ] Phase 1: Load tool profile YAML
- [ ] Phase 2: Run landscape-intel.sh (or sub-scripts)
- [ ] Phase 3: Read channel state files (delta window)
- [ ] Phase 4: Synthesize traction table (signal | source | date | confidence)
- [ ] Phase 5: Cross-link LANDSCAPE_SYNTHESIS.md technical gaps
- [ ] Phase 6: Flag product shifts affecting fork priorities
- [ ] Phase 7: Write combined LANDSCAPE_INTEL digest
- [ ] Phase 8: Update state files
```

### Phase 4: Traction table template

| Signal | Source | Date | Confidence | Notes |
|--------|--------|------|------------|-------|
| Work Surfaces 0.7.1 | Discord #announcements | 2026-07-07 | high | ... |
| HN front page #12 | Discord + web | 2026-07-07 | high | ... |

Confidence: **high** = primary source (Discord official, GitHub release); **medium** = secondary (HN, blog); **low** = rumor/unverified chatter.

## Discord ingestion (three paths)

### Path A — opencli (no bot)

Prerequisites: Discord Desktop running; `opencli` installed.

```bash
opencli discord-app status
# Navigate to #announcements, extract visible messages (agent-assisted)
./scripts/landscape-discord-ingest.sh --profile rowboat --method opencli
```

If `SETUP_NEEDED`: install opencli per [discord-reader](https://skills.sh/himself65/finance-skills/discord-reader) pattern.

### Path B — Discord Bot MCP (when bot invited)

1. Create bot at [Discord Developer Portal](https://discord.com/developers/applications)
2. Enable **Message Content Intent**
3. Invite bot to server; note guild ID + `#announcements` channel ID → profile YAML
4. Merge [`.devdocs/MCP_DISCORD.template.json`](../../tools/rowboat-quickstart/.devdocs/MCP_DISCORD.template.json) into `~/.cursor/mcp.json`
5. Token via 1Password (`op-credentials` skill) — **never commit**

```bash
./scripts/landscape-discord-ingest.sh --profile rowboat --method mcp
```

Agent uses MCP `list_messages` / channel history tools when MCP is configured.

### Path C — manual archive (fallback)

Paste announcements to `sources/discord/manual/*.md`; ingest with:

```bash
./scripts/landscape-discord-ingest.sh --profile rowboat --method file
```

## YouTube

Uses continuous-ai stack (`youtube-metadata-extractor.py`, optional `transcript-summarizer.py`).

Profile `youtube_watchlist` URLs → transcripts, comments, chapters under `sources/youtube/`.

## Web traction

Uses `parallel-cli search` (parallel-web-search skill). Every synthesized claim needs inline citation from JSON output.

Rowboat queries in profile: YC S24, HN, funding, Work Surfaces, pricing tiers.

## Gates

- No upstream-visible GitHub actions without user review (see `rowboat-upstream-digest` / AGENTS.md)
- Discord bot token never in repo
- Web claims must cite parallel-cli JSON sources

## Related skills

- **rowboat-upstream-digest** — git-only child workflow
- **rowboat-fork-workflow** — branch/sync policy
- **parallel-web-search** — parallel-cli search format
- **op-credentials** — Discord bot token from 1Password

## Troubleshooting

| Problem | Action |
|---------|--------|
| `parallel-cli` not found | Run `/parallel-setup` |
| opencli not ready | Use `--discord-method file` |
| MCP discord fails | Check token, Message Content intent, guild allowlist |
| YouTube skip | Ensure `yt-dlp` in continuous-ai venv |
