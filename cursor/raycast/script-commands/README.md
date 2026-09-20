# Cursor Classic Raycast script commands

Raycast **Store** extensions are integrity-checked. Editing
`~/.config/raycast/extensions/<id>/*.js` (including the old
`just patch-raycast-cursor` rewrite) makes Raycast show:

> Could not load command — The entry point file appears to be corrupted

These script commands live in this repo and call
`cursor/scripts/cursor-classic-open.py`, which launches
`cursor --classic`. They are not hashed by the Store.

## Add the folder once

1. Open Raycast Settings → Extensions.
2. Script Commands → **Add Script Directory**.
3. Choose this directory:

   `~/dotfiles/cursor/raycast/script-commands`

Or from a terminal:

```bash
cd ~/dotfiles/cursor
just install-raycast-classic
```

That opens this folder in Finder so you can paste the path into Raycast.

## Commands

| Raycast title | What it does |
| --- | --- |
| Search Recent Projects (Classic) | Opens a recent workspace/folder by name fragment (`pet-master`, `rrid`, …). Empty argument lists recent items. |
| Open Finder Selection in Classic | Opens the Finder selection, or the front Finder window. |
| Open New Classic Window | `cursor --classic --new-window` |

Disable or ignore the Store **Cursor** extension (`degouville/cursor-recent-projects`) if you do not want `open -a Cursor` (no `--classic`) to win when you type the same titles.

After adding the directory, quit Raycast from the menu bar (`Cmd+Q` while it is focused) and reopen it if the new commands do not appear.
