# Cursor Classic (local Raycast fork)

MIT fork of [degouville/cursor-recent-projects](https://www.raycast.com/degouville/cursor-recent-projects)
from [raycast/extensions](https://github.com/raycast/extensions/tree/main/extensions/cursor-recent-projects).

The Store copy calls `open(path, "Cursor")` (`open -a Cursor`) and cannot pass
`--classic`. Editing the installed Store JS makes Raycast reject the entry point.

This folder is a **development / imported** extension. It opens projects through
`~/dotfiles/cursor/scripts/cursor-classic-wrapper.sh`.

## Install (once)

1. Leave the Store **Cursor** extension disabled (same titles would collide).
2. Raycast must be running.
3. From this repo:

```bash
cd ~/dotfiles/cursor
just develop-raycast-classic
```

That runs `npm install` and `npm run dev` (`ray develop`). Raycast should show
**Cursor Classic** under Extensions. Keep that terminal open the first time
until the commands appear, then you can stop the watcher; Import Extension
also works: Raycast Settings → Extensions → **Import Extension** → this folder.

## After a Raycast major upgrade (Missing executable)

Raycast v2 copies a stub into `~/.config/raycast/extensions/cursor-classic`
(`package.json` + assets, no compiled JS). The extension list still shows
**Cursor Classic**, but commands fail with *Missing executable*. Rebuild from
this source (not the stub, not the Store copy):

```bash
cd ~/dotfiles/cursor
just develop-raycast-classic
```

There is no separate Cursor project for Raycast extensions. Source of truth is
this folder inside `~/dotfiles/cursor`. Opening macosx-tools is fine; do not
Import Extension from `~/.config/raycast/extensions/cursor-classic`.

Search Recent Projects defaults to **Folders + Workspaces** (local folders and
`.code-workspace` files). **All Types** still includes individual files.

## Re-sync from upstream

```bash
# refresh source from github.com/raycast/extensions, then re-apply open-classic.ts
# (do not overwrite src/open-classic.ts or the three patched call sites)
```

Patched call sites:

- `src/contexts/ProjectContext.tsx` — Search Recent Projects
- `src/open-with-cursor.ts` — Open with Cursor
- `src/open-new-window.ts` — Open New Window
