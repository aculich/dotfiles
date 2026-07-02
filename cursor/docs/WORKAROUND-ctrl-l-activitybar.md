# Workaround: `Ctrl+L` → "Unknown part workbench.parts.activitybar"

**Status:** active workaround (applied 2026-07-02, Cursor 3.10.5)
**Affected file:** `cursor/keybindings.json`

## Symptom

Pressing `Ctrl+L` in an editor pops an error notification:

```
Unknown part workbench.parts.activitybar on layout wb?; have:
workbench.parts.statusbar, workbench.parts.editor, workbench.parts.titlebar,
workbench.parts.banner, workbench.parts.panel, workbench.parts.auxiliarybar,
workbench.parts.sidebar, workbench.parts.unifiedsidebar,
workbench.parts.embeddedAuxBarEditor
```

Navigation right does not happen.

## Root cause (Cursor bug, not a keybindings bug)

Our long-standing binding `ctrl+l` → `workbench.action.navigateRight` (the
vspacecode-style `Ctrl+H/J/K/L` window-navigation set) is the trigger, but the
failure is inside Cursor itself:

1. `navigateRight` calls the layout service's `getVisibleNeighborPart()`, which
   iterates candidate parts including `workbench.parts.activitybar`.
2. Cursor's new **unified-sidebar layout** (the agents sidebar,
   `workbench.parts.unifiedsidebar` in the "have:" list above) does not
   register an activity bar part.
3. The code guards the activity-bar probe with `this.activityBarPartView`, but
   the guard passes when the activity-bar *view object* exists while the part
   is not registered on the specific layout instance being queried. The `wb?`
   in the message is the workbench index of a secondary/embedded workbench
   layout. `getPart("workbench.parts.activitybar")` then throws.

Evidence was gathered by grepping Cursor's bundle
(`/Applications/Cursor.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.js`)
for the `Unknown part` throw site (`getPart`) and the `navigateRight`
implementation (`getVisibleNeighborPart`).

The regression arrived with the Cursor app update that introduced the unified
sidebar — it coincided with, but was not caused by, a keybindings merge (the
merged `ctrl+l` → `file-browser.stepIn` binding only matches
`when: inFileBrowser` and cannot fire in a normal editor).

## Workaround applied

Replaced `workbench.action.navigateRight` with
`workbench.action.focusRightGroup` in the two `ctrl+l` bindings that used it:

- the general editor binding (`!terminalFocus && ... && !isInDiffEditor`)
- the diff-editor binding (`isInDiffEditor && !isInDiffLeftEditor`)

`focusRightGroup` only moves focus between **editor groups**, so it never
performs the cross-part neighbor lookup that hits the bug.

**Trade-off:** `Ctrl+L` no longer hops from the editor into the
sidebar/panel/auxiliary bar to the right. `Ctrl+H/J/K` still use the
`navigate*` commands and retain cross-part behavior (leftward/vertical
navigation has not exhibited the bug, since the activity bar probe happens on
the rightward path with the unified sidebar).

## Related cleanup

Removed a dead binding in the same file:

```json
{ "key": "ctrl+l", "when": "terminalFocus",
  "command": "-workbench.action.showActivityBar" }
```

`workbench.action.showActivityBar` no longer exists anywhere in the Cursor
3.10.5 bundle, so the removal binding was a no-op.

## How to revert

When Cursor fixes the layout-service bug (test: run
`workbench.action.navigateRight` from the command palette with the agents
sidebar open — no error notification should appear), restore the original
command in both bindings:

```json
{ "key": "ctrl+l", "command": "workbench.action.navigateRight", "when": "..." }
```

and delete this document plus the pointer comments in `keybindings.json`.

## Reporting

Reproduction for a Cursor bug report: with the unified agents sidebar enabled,
focus an editor and run **View: Navigate to the View on the Right**
(`workbench.action.navigateRight`). The "Unknown part
workbench.parts.activitybar" error notification appears and navigation fails.
