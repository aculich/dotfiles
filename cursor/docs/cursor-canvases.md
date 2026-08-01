# Cursor canvases

**Version pin:** [cursor-internals-VERSION.md](cursor-internals-VERSION.md).

## What they are

Interactive React artifacts (dashboards, tables, charts, custom UI) that agents create beside chat. In the Agents Window they are durable side-panel artifacts alongside terminal, browser, and SCM ([Cursor blog — Canvases](https://cursor.com/blog/canvas), [docs](https://cursor.com/docs/agent/tools/canvas)).

Built-in skill: `/canvas`. Marketplace example: Docs Canvas skill.

## Opening & sharing

- Card at end of agent response; Command Palette **Open Canvas**; Agents Window new-tab menu ([docs](https://cursor.com/docs/agent/tools/canvas)).
- **Share:** paid plans; uploads a live snapshot link for teammates; blocked by Legacy Privacy Mode ([docs](https://cursor.com/docs/agent/tools/canvas)).

## On-disk location (`confirmed`)

Managed canvases compile from:

```text
~/.cursor/projects/<project-id>/canvases/*.canvas.tsx
~/.cursor/projects/<project-id>/canvases/*.canvas.data.json   # optional companion data
```

`<project-id>` encodes the workspace path (`/` → `-`), e.g. `Users-me-dotfiles-cursor`.

This path is **outside the git repo**, so canvases are not version-controlled unless you mirror them. Community request: allow `.canvas.tsx` inside the workspace with sync to managed storage ([forum](https://forum.cursor.com/t/allow-canvas-tsx-inside-workspace-repo-git-with-optional-sync-to-managed-canvases/159617)).

Official docs do **not** currently document this filesystem layout (`suspected` that product may change).

## VCS patterns

1. **Catalog only** — `scripts/catalog-cursor-canvases.sh`
2. **Manual mirror** — copy/symlink into `<project>/.cursor/canvases/` and commit (IDE may still need managed path; see [cursor-canvas-web](https://github.com/thisismydesign/cursor-canvas-web) dual-path pattern)
3. **Web shim** — `@thisismydesign/cursor-canvas-web` reimplements `cursor/canvas` for Vite/static hosting
4. **ChatStory lane (planned)** — archive managed canvases into PFV vault (see SuperPRD gap analysis)

## API surface

Canvases import only from `cursor/canvas` (IDE-provided module). Not an npm package; outside Cursor you need a shim ([cursor-canvas-web](https://github.com/thisismydesign/cursor-canvas-web)).

## Related

- [cursor-storage-map.md](cursor-storage-map.md)
- Ops canvas for this repo: path in [`.context/conventions.md`](../.context/conventions.md) (`status_canvas`)
