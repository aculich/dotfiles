# Keybinding observability and modification (Cursor / VS Code)

Guide to inspecting, troubleshooting, and overriding keyboard shortcuts so the right command runs in the right context. Cursor uses the same keybinding system as VS Code.

---

## Quick reference: commands to run

| Goal | Command (Cmd+Shift+P) |
|------|------------------------|
| See which command runs when you press a key | **Developer: Toggle Keyboard Shortcuts Troubleshooting** |
| List all bindings for a key and see conflicts | **Preferences: Open Keyboard Shortcuts** → search key → right‑click → **Show Same Keybindings** |
| See current context (e.g. `editorLangId`) for a focused element | **Developer: Inspect Context Keys** → click the element |
| View default + extension keybindings (JSON) | **Preferences: Open Default Keyboard Shortcuts (JSON)** |
| Edit your overrides | **Preferences: Open Keyboard Shortcuts (JSON)** (opens `keybindings.json`) |

---

## 1. Observability: how keypresses become commands

### 1.1 Live logging (Toggle Keyboard Shortcuts Troubleshooting)

**Command:** `Developer: Toggle Keyboard Shortcuts Troubleshooting`

- Turns on logging for the keybinding service.
- The **Output** panel shows a log; choose the keybinding / keyboard channel.
- Press any key; the log shows:
  - The key resolved (e.g. `[Tab]`).
  - How many keybinding entries matched that key.
  - **Which command won**: command id, full `when` clause, and **source** (built-in, User, or extension name).
  - Then: `Invoking command <commandId>`.

Use this when a key does the “wrong” thing: you see exactly which binding won and why (its `when` and source).

**Example log:**

```
[KeybindingService]: | Resolving [Tab]
[KeybindingService]: \ From 16 keybinding entries, matched extension.vim_tab, when: editorTextFocus && vim.active && !inDebugRepl && !inlineEditIsVisible && vim.mode != 'Insert', source: user extension vscodevim.vim.
[KeybindingService]: + Invoking command extension.vim_tab.
```

So Tab was handled by Vim’s `extension.vim_tab` in that context.

### 1.2 Keyboard Shortcuts editor: same key, all bindings

**Command:** `Preferences: Open Keyboard Shortcuts` (or **Cmd+K Cmd+S**)

- Search by **key** (e.g. type `tab`) to list every binding for that key.
- Columns: **Command**, **Keybinding**, **When**, **Source**.
- Right‑click a row → **Show Same Keybindings** to see every rule that shares that key (who is shadowing whom).

Use this to see all candidates for a key and compare their `when` clauses and sources.

### 1.3 Inspect context keys

**Command:** `Developer: Inspect Context Keys`

- After running it, click any UI element (editor, terminal, panel, magit buffer).
- The developer tools / console (or panel) shows the **current context** for that element, e.g.:
  - `editorLangId`
  - `terminalFocus`, `vim.active`, `vim.mode`
  - `focusedView`, `panelFocus`
  - etc.

Use this to write accurate `when` clauses (e.g. for removal or override) when you’re not sure of the exact context (e.g. Magit buffer’s `editorLangId`).

### 1.4 Default keybindings (JSON)

**Command:** `Preferences: Open Default Keyboard Shortcuts (JSON)`

- Opens the built-in + extension keybinding list in JSON form.
- Search for a key or command to see the exact `key`, `command`, and `when` from defaults and extensions.

Use this to copy or adapt `when` clauses when writing overrides in your own `keybindings.json`.

---

## 2. How resolution works (why one binding wins)

- Rules are evaluated **bottom to top** in the merged list (defaults + extensions + user).
- **User** keybindings (your `keybindings.json`) are merged in and typically evaluated in a way that lets them override.
- For each keypress, the **first** rule that matches both the **key** and the **when** clause is chosen; that command runs and no further rules are checked.
- So “shadowing” = another binding with the same key has a `when` that matches first in your current context.

To give a binding priority in a specific context, either:

- **Remove** the competing binding (in that context or globally), or  
- **Add** a user rule with a **narrower** `when` that matches only when you want your command to run (so it’s the first match in that context).

---

## 3. Modification patterns

### 3.1 Removing a keybinding

**In Keyboard Shortcuts UI:** Right‑click the row → **Remove Keybinding**.

**In `keybindings.json`:** Add a **removal** rule: same `key`, command prefixed with `-`:

```json
{ "key": "tab", "command": "-extension.vim_tab" }
```

Optional: add a `when` so the binding is removed only in that context:

```json
{ "key": "tab", "command": "-extension.vim_tab", "when": "editorTextFocus && editorLangId == 'magit'" }
```

(If the removal’s `when` doesn’t match in your situation, the extension binding stays active; see “Context-specific removal not matching” below.)

### 3.2 Overriding: run a different command for the same key

Add a user rule with the same `key`, your desired `command`, and a `when` that is true when you want your command to run. Your rule will be considered before or alongside others; with a sufficiently specific `when` it will win in that context.

### 3.3 Disabling a key entirely (no-op)

```json
{ "key": "tab", "command": "" }
```

Use sparingly; prefer removing or narrowing the binding you don’t want.

### 3.4 Global remove + re-add (aggressive override)

When a **context-specific removal** doesn’t work (e.g. you don’t know the exact `editorLangId` or the removal’s `when` doesn’t match):

1. **Remove** the binding **globally** (no `when`):
   ```json
   { "key": "tab", "command": "-extension.vim_tab" }
   ```
2. **Re-add** it only where you still want it, with a `when` that **excludes** the context where you want another command to win:
   ```json
   {
     "key": "tab",
     "command": "extension.vim_tab",
     "when": "editorTextFocus && vim.active && !inDebugRepl && !inlineEditIsVisible && vim.mode != 'Insert' && !(editorLangId =~ /magit/)"
   }
   ```

Effect: the extension’s default is gone everywhere; your re-add restores it only outside Magit (or whatever the regex matches). In Magit, Tab is no longer handled by that command, so another binding (e.g. Magit Toggle Fold) can win.

---

## 4. When clauses: useful context keys

Common keys you can use in `when`:

| Context key | Typical meaning |
|-------------|------------------|
| `editorTextFocus` | Editor has focus |
| `editorLangId == 'magit'` | Language id (exact) |
| `editorLangId =~ /magit/` | Language id contains "magit" |
| `terminalFocus` | Terminal has focus |
| `vim.active`, `vim.mode != 'Insert'` | Vim extension state |
| `inDebugRepl`, `inlineEditIsVisible` | Debug / inline edit |
| `focusedView`, `panelFocus` | Which view/panel is focused |

Operators: `==`, `!=`, `=~` (regex), `&&`, `||`, `!`.

---

## 5. Example: Tab in edamagit (Magit Toggle Fold vs Vim Tab)

**Problem:** In Magit/edamagit buffers, Tab should run **Magit Toggle Fold**, but **Vim’s Tab** (`extension.vim_tab`) was winning.

**Cause:** The extension’s default Tab binding had a `when` that matched in the Magit buffer (e.g. `editorTextFocus && vim.active && !inDebugRepl && !inlineEditIsVisible && vim.mode != 'Insert'`), and that rule was chosen before Magit Toggle Fold’s.

**Attempts:**

1. **Minimal:** Remove Vim Tab only when in Magit, e.g.  
   `"when": "editorTextFocus && (editorLangId == 'magit' || editorLangId == 'edamagit-cursor-c')"`  
   In practice the removal’s `when` often didn’t match (e.g. different or unknown `editorLangId`), so the extension binding stayed active.

2. **Robust:** Global remove + re-add:
   - Remove `extension.vim_tab` for `tab` with **no** `when`.
   - Re-add `extension.vim_tab` for `tab` with the same conditions as the extension **plus** `!(editorLangId =~ /magit/)` so any buffer whose language id contains `"magit"` is excluded.  
   Result: Tab in Magit buffers is no longer handled by Vim, so Magit Toggle Fold can run; elsewhere Vim still gets Tab.

**Takeaway:** If a context-specific removal doesn’t work, use global remove + re-add with an exclusion condition (e.g. regex on `editorLangId`) so you don’t depend on the exact context value.

---

## 6. References

- [Keyboard shortcuts (VS Code)](https://code.visualstudio.com/docs/getstarted/keybindings) – conflicts, troubleshooting, rules, removal.
- [When clause contexts (Extension API)](https://code.visualstudio.com/api/references/when-clause-contexts) – context keys and operators.
- [Cursor keyboard shortcuts](https://cursor.com/docs/reference/keyboard-shortcuts) – Cursor-specific shortcuts (e.g. terminal prompt bar, Cmd+K).

---

*This guide lives next to `keybindings.json`; the JSON file’s top comments point here for full observability and modification details.*
