# Cursor tooling ontology & awesome-list provenance

**Hard filter:** tool must support **Cursor** (IDE and/or Cursor CLI).  
**Tiers:** P0 Cursor-specific → P1 Cursor+Grok → P2 Cursor+1–3 majors → P3 Cursor+ocean → footnote (no Cursor).

## Awesome-list sources

| List | URL | Relevance |
|------|-----|-----------|
| awesome-cursor | https://github.com/hao-ji-xing/awesome-cursor | Primary — SpecStory, Cursor Stats, CursorLens, stagewise, MCP helpers |
| awesome-cursorrules | https://github.com/PatrickJS/awesome-cursorrules | Adjacent (rules packs; low weight for session archive) |
| awesome-cursor-rules-mdc | https://github.com/sanjeed5/awesome-cursor-rules-mdc | Adjacent rules |

Extract dump: [research/awesome-cursor-extract.json](research/awesome-cursor-extract.json).

## Ontology categories

| Category | Question |
|----------|----------|
| Session archive | Persist chats/composer/agent as files |
| Export / migrate | Bulk export; machine/workspace move |
| Replay / observability | Browse, timeline, TUI, dashboard over stores |
| Telemetry / cost | Usage meters, generation logs |
| Canvas / artifact VCS | Canvases, plans into git |
| Rules / skills / hooks | Outer harness (lower weight unless session data) |
| Cloud sync | Optional cloud RAG/share |

## Roster (Cursor-required)

| Slug | Tier | Categories | Notes |
|------|------|------------|-------|
| chatstory | **P0** | archive, plans, multi-machine | Ours — PFV vault |
| cursor-history | **P0** | export, migrate, CLI | OSS CLI |
| cursor-chat-export | **P0** | export | Python |
| cursor-chat-recovery-kit | **P0** | migrate | Rename recovery |
| cursor-export | **P0** | export | WooodHead |
| cursor-chat-browser | **P0** | browse, export | Web UI over DB |
| cursor-chat-bulk-export | **P0** | export | Marketplace extension |
| cursor-canvas-web | **P0** | canvas VCS | Web shim |
| cursor-stats | **P0** | telemetry | Status bar usage |
| cursorlens | **P0** | telemetry, observability | Dashboard / gen logs |
| vibe-replay | **P2** | replay | Cursor+Claude+Codex+Pi |
| agentgrep | **P2** | search adapters | cursor-ide backend |
| specstory | **P3** | archive, cloud, multi-IDE | Ocean breadth |
| mantra | **P3** | replay, multi-tool | Cross-tool |
| coco | footnote* | orchestration | Multi-agent; not session archive focus |
| stagewise | footnote* | browser↔editor | Not history |
| tribecode | **footnote** | telemetry | Cursor “Coming Soon” |

\*Listed on awesome-cursor; included for ontology completeness; deep cluster deferred unless archive/observe session data.

## Adjacent (not deep-harvested)

Rules packs, MCP installers, llm-router, curxy (Ollama proxy), CursorFocus — see awesome-cursor README. Useful for outer harness, not SuperPRD session-data matrix unless they touch `state.vscdb` / transcripts.
