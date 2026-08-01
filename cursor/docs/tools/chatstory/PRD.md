# PRD: chatstory

- **Slug:** `chatstory`
- **Tier:** P0
- **License / model:** AGPL-3.0
- **Delivery:** extension

## Problem

SpecStory-style capture with lower resource cost; Cursor-only dual-DB correctness; multi-machine PFV vault.

## ICP / users

Cursor power users with many windows; teams wanting git-backed history without SpecStory Cloud.

## Jobs to be done

1. Auto-archive Agent/Composer chats to markdown
2. Capture plans
3. Sync vault across machines via git
4. Local usage estimates

## Cursor surfaces supported

- [x] Chats/Composer/Agent
- [x] Plans

## Non-goals

- Canvases
- Settings snapshot
- Multi-IDE
- TUI
- SpecStory Cloud

## Differentiation vs ChatStory

Unique PFV multi-node git vault; Cursor-only; no canvases yet.
