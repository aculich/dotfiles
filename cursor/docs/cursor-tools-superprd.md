# SuperPRD — Cursor session & observability tools

**Version pin:** [cursor-internals-VERSION.md](cursor-internals-VERSION.md).  
**Ontology:** [cursor-tools-ontology.md](cursor-tools-ontology.md) · **Clusters:** [tools/](tools/) · **Short index:** [cursor-tooling-landscape.md](cursor-tooling-landscape.md)

Longform synthesis of every `tools/*/FEATURES.md`. Hard filter: **Cursor support required** (tribecode = footnote only).

## 1. Unified capability catalog

| ID | Capability / use case |
|----|------------------------|
| F-ARCHIVE-MD | Continuously or on-demand persist sessions as markdown (or equivalent files) |
| F-EXPORT-BULK | Bulk export many sessions at once |
| F-MIGRATE-WS | Move/recover sessions across workspace hashes or machines |
| F-SEARCH | Keyword / full-text search across sessions |
| F-REPLAY-TUI | Interactive browse, timeline, TUI, or dashboard replay |
| F-PLANS | Capture or sync Cursor Plan Mode files |
| F-CANVAS | Capture, mirror, or deploy canvases |
| F-SETTINGS | Snapshot IDE/agent settings (non-secret) |
| F-MULTI-MACHINE | Sync history across laptops (git/cloud) |
| F-CLOUD | Optional vendor/self-hosted cloud sync or share |
| F-COST | Usage / token / subscription cost visibility |
| F-LOCAL-ONLY | Usable without mandatory cloud |

### Additional use cases (cross-cutting)

- UC-DEBUG-DB — Inspect `state.vscdb` keys when history “disappears”
- UC-TEAM-INTENT — Commit AI reasoning beside code for PRs
- UC-OBS-LIVE — Real-time view of all projects/windows/plans/canvases (gap — no tool fully owns this)
- UC-CANVAS-VCS — Stop losing canvases outside git
- UC-PRIVACY — Local-first with PII scrub / no share links

## 2. Tool × feature matrix

Legend: **Y** / **P** (partial) / **N** / **—** (footnote / N/A)

| Tool | Tier | ARCHIVE | EXPORT | MIGRATE | SEARCH | REPLAY | PLANS | CANVAS | SETTINGS | MULTI | CLOUD | COST | LOCAL |
|------|------|---------|--------|---------|--------|--------|-------|--------|----------|-------|-------|------|-------|
| chatstory | P0 | Y | Y | P | Y | N | Y | N | N | Y | P | Y | Y |
| cursor-history | P0 | P | Y | Y | Y | N | N | N | N | P | N | N | Y |
| cursor-chat-export | P0 | P | Y | N | P | N | N | N | N | N | N | N | Y |
| cursor-chat-recovery-kit | P0 | N | P | Y | P | N | N | N | N | P | N | N | Y |
| cursor-export | P0 | P | Y | N | N | N | N | N | N | N | N | N | Y |
| cursor-chat-browser | P0 | P | Y | N | P | P | N | N | N | N | N | N | Y |
| cursor-chat-bulk-export | P0 | P | Y | N | N | N | N | N | N | N | N | N | Y |
| cursor-canvas-web | P0 | N | N | N | N | N | N | Y | N | P | N | N | Y |
| cursorlens | P0 | N | P | N | P | P | N | N | P | N | P | Y | P |
| cursor-stats | P0 | N | N | N | N | N | N | N | N | N | N | Y | Y |
| vibe-replay | P2 | P | Y | N | P | Y | N | N | N | N | N | P | Y |
| agentgrep | P2 | N | N | N | Y | N | N | N | N | N | N | N | Y |
| specstory | P3 | Y | Y | P | Y | P | N | N | N | P | Y | N | P |
| mantra | P3 | P | Y | N | Y | Y | N | N | N | N | N | N | Y |
| tribecode | footnote | — | — | — | — | — | — | — | — | — | Y | Y | P |

## 3. Tool × Cursor surface

| Tool | Chat/Composer/Agent | Plans | Canvases | Settings | Transcripts/DB | Cursor CLI |
|------|---------------------|-------|----------|----------|----------------|------------|
| chatstory | Y | Y | N | N | Y (sqlite) | N |
| cursor-history | Y | N | N | N | Y | N |
| cursor-chat-* exporters | Y | N | N | N | Y | N |
| cursor-canvas-web | N | N | Y | N | N | N |
| cursorlens / cursor-stats | telemetry | N | N | P | P | N |
| vibe-replay | Y | N | N | N | Y | N |
| specstory | Y | N | N | N | Y | Y |
| mantra | Y | N | N | N | Y | N |

## 4. Delivery form × locality

| Tool | Form | Locality |
|------|------|----------|
| chatstory | Extension | Local vault; optional self-host + git |
| specstory | Extension + CLI + Cloud | Local-first; Cloud opt-in |
| cursor-history | CLI | Local |
| vibe-replay | CLI + HTML | Local / offline share |
| cursor-canvas-web | Library | Local + static host |
| cursorlens | Dashboard | Local or hosted |
| cursor-stats | Extension | Local UI over account usage |

## 5. Provider breadth (priority signal)

| Tool | Cursor | Grok | Claude | Gemini | Codex | Other |
|------|--------|------|--------|--------|-------|-------|
| chatstory | Y | — | planned v0.3 | — | — | — |
| Most P0 exporters | Y | — | — | — | — | — |
| vibe-replay | Y | — | Y | — | Y | Pi |
| specstory | Y | — | Y | Y | Y | Copilot, Droid, … |
| mantra | Y | — | Y | — | — | Windsurf, … |
| tribecode | soon | — | Y | Y | Y | — |

## 6. Gap analysis for ChatStory

| Gap | Present in | Recommendation |
|-----|------------|----------------|
| F-CANVAS | cursor-canvas-web | **Build** vault capture + optional project mirror |
| F-REPLAY-TUI / UC-OBS-LIVE | vibe-replay, cursor-chat-browser | **Build** thin `chatstory inspect` CLI; don’t abandon extension |
| F-MIGRATE-WS depth | cursor-history, recovery-kit | **Adopt patterns** / optional shell-out; keep PFV path_history |
| F-SETTINGS | none strong | **Build** periodic non-secret settings snapshot into vault meta |
| SpecStory Cloud share | specstory | **Ignore** — self-host/git only |
| Multi-IDE ocean | specstory, mantra | **Defer** to v0.3+ adapters |

### Unique ChatStory strengths

- Partitioned Federated Vault (multi-machine git without path collisions)
- Plans capture + plan_index
- In-extension Cursor-only (no Go watch farm)
- Usage estimates in history

## 7. Recommendations (build / adopt / ignore)

| Action | What |
|--------|------|
| **Keep** | ChatStory as Cursor archive SoT |
| **Adopt (read-only)** | `cursor-history` + `vibe-replay` for inspect UX inspiration / temporary observability |
| **Adopt (pattern)** | cursor-canvas-web dual-path for canvas VCS |
| **Ignore as replacement** | SpecStory/Mantra oceans; tribecode until Cursor support |
| **Build next** | (1) canvases lane (2) settings snapshot (3) `chatstory inspect` CLI/TUI |

## 8. Cluster index

| Slug | Path |
|------|------|
| chatstory | [tools/chatstory/](tools/chatstory/) |
| specstory | [tools/specstory/](tools/specstory/) |
| cursor-history | [tools/cursor-history/](tools/cursor-history/) |
| … | see [tools/](tools/) |
