# Agent context (`.context/`)

This directory holds **eleven markdown files** (nine core + **outcomes** + **monitor**) for Intent, Context, Values, and outcome measurement for the **Cursor ops hub** (`~/dotfiles/cursor`).

## Read order

1. **`conventions.md`** — paths and automation hints  
2. **`intent.md`** — what success means  
3. **`outcomes.md`** — desired vs expected outcomes and indicators  
4. **`values.md`** — guardrails and guiderails  
5. **`project.md`** — summary and pointers  
6. **`monitor.md`** — recurring ops watch  
7. Others as needed (`people`, `decisions`, `next-actions`, `domain-knowledge`)

## Three pillars

> Intent tells context what to want; context tells intent what to mean.

**Values** constrain both: guardrails (MUST NOT) and guiderails (SHOULD).

## Status dashboard

Interactive Cursor canvas (IDE-managed path, not in this repo):

`/Users/me/.cursor/projects/Users-me-dotfiles-cursor/canvases/cursor-ops-status.canvas.tsx`

Refresh by re-embedding a live snapshot (canvas cannot `fetch`). Default CLI health: `just status` from this directory.

See **`context-engineering`** skill for lifecycle and bootstrap.
