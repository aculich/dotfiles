# Open workspaces in classic Cursor IDE (`--classic`)

**Date:** 2026-08-13  
**Status:** Local workaround. Cursor has no official “always IDE” default.

Cursor 3 routes many `.code-workspace` / folder opens into the **Agents Window** (layout name “glass”) when that was the last focused window. Staff document `--classic` on the forum; it is also in `cursor --help`. There is **no** `settings.json`, `~/.cursor/argv.json`, or `~/.cursor/cli-config.json` key that makes `--classic` the default.

## What this repo installs

| Piece | Role |
| --- | --- |
| [`scripts/cursor-classic-wrapper.sh`](../scripts/cursor-classic-wrapper.sh) | Injects `--classic` on editor launches |
| [`scripts/install-cursor-classic-cli.sh`](../scripts/install-cursor-classic-cli.sh) | Points Homebrew / `/usr/local` `cursor` at the wrapper. Leaves `~/.local/bin/cursor` alone when that file is Cursor’s `cursor.com/install` agent shim. |
| [`zsh/aliases.d/10-cursor-classic.zsh`](../../zsh/aliases.d/10-cursor-classic.zsh) | Interactive zsh function (same wrapper) |

```bash
cd ~/dotfiles/cursor
just install-classic-cli     # ~/.local/bin/cursor + writable /usr/local/bin/cursor
just classic-cli-status
```

After install, these all open the **classic IDE**:

```bash
cursor ~/projects/workspaces/pet-master.code-workspace
cursor .
cursor editor ~/projects/rrid-ucb/rrid-ucb.code-workspace
```

You do not need to type `--classic` (Raycast history can drop it).

**Raycast Shell:** this machine’s Homebrew `cursor` is wrapped (`/opt/homebrew/bin/cursor`). If a Raycast command still opens Agents Window, put `/opt/homebrew/bin` first in Raycast Settings → Advanced → PATH (or run `which cursor` inside that Shell command). `/usr/local/bin/cursor` is root-owned and was left as the official CLI.

**Raycast Store Cursor extension** (`degouville/cursor-recent-projects`) does **not** use the `cursor` CLI. It calls Raycast `open(path, "Cursor")` (`open -a Cursor`) and cannot pass `--classic`. Re-enabling it will keep opening Agents Window. Do **not** rewrite its installed JS — Raycast integrity-checks Store entry points.

Maintain a local fork instead: [`raycast/cursor-classic-extension/`](../raycast/cursor-classic-extension/FORK.md). Keep the Store **Cursor** extension **disabled**.

```bash
cd ~/dotfiles/cursor
just develop-raycast-classic
```

Raycast must be running. That registers **Cursor Classic** (Search Recent Projects, Open with Cursor, Open New Window) via `ray develop`. Or: Settings → Extensions → **Import Extension** → `~/dotfiles/cursor/raycast/cursor-classic-extension`.

Script-command fallback (no npm): [`raycast/script-commands/`](../raycast/script-commands/README.md) and `just install-raycast-classic`, then Add Script Directory. Those commands did not appear from `just install-raycast-classic` alone — Raycast never auto-registers that folder.

**Cursor** vs **Cursor 2** in Raycast Applications is unrelated (Cursor 2 is `/Applications/Cursor 2.app`, an iOS wrapper). The classic wrapper is the `cursor` CLI, not a second Mac app.

If the Store Cursor commands still show a corruption error, quit Raycast (`Cmd+Q` while focused) and reopen. Undo leftovers: `just unpatch-raycast-cursor`.

### What is not wrapped

| Invocation | Behavior |
| --- | --- |
| `cursor agent …` | Pass-through to `cursor-agent` |
| `cursor tunnel …` | Pass-through |
| Already has `--classic` | Unchanged |
| `cursor --glass …` | Agents Window (opt-in) |
| `CURSOR_CLASSIC=0 cursor …` | Official CLI, no inject |

`open -a Cursor file.code-workspace` **cannot** pass `--classic`. Prefer the `cursor` CLI. Finder/double-click still uses LaunchServices and can land in Agents Window.

If Cursor’s palette **Shell Command: Install ‘cursor’ command in PATH** (or `brew reinstall --cask cursor`) restores the official symlink, re-run `just install-classic-cli`.

## App-side restore (dock / icon, not CLI)

CLI and dock use **different** paths. For dock launches:

1. Cursor Settings (`Cmd+Shift+J`) → **General → Startup → Window Restoration** → **Last Used Windows** (3.12+; older builds: **Open Agents Window on startup** off).
2. Command Palette → **Open IDE**.
3. Close Agents Window. Quit (`Cmd+Q`) while an **Editor** window is focused.

That restores the last window type; it does **not** make bare `cursor path` ignore a last-focused Agents Window. The wrapper covers that.

In-session escape: Command Palette → **Open IDE**.

## Related

- [Agents Window (official)](https://cursor.com/docs/agent/agents-window.md)
- [Forum: CLI launch opens Agent panel](https://forum.cursor.com/t/cli-launch-always-opens-agent-panel-instead-of-ide/166537)
- [agents-window-hygiene.md](agents-window-hygiene.md)
- [MULTIROOT-cursor-lifecycle.md](MULTIROOT-cursor-lifecycle.md)
