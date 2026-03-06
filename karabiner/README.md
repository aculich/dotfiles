# Karabiner-Elements rules (dotfiles backup)

Preserved **Caps Lock → Escape / Control** rules so you can restore or toggle between them.

## Files

| File | Behavior |
|------|----------|
| `caps_lock-ctrl-bracket.json` | Tap → **Ctrl+[** (same as Escape in terminals/zsh). Hold → Control. Use this when Esc+key (e.g. Esc+z) should work. |
| `caps_lock-escape.json` | Tap → **Escape**. Hold → Control. Same idea; the ESC version can fail to trigger Esc+key in some terminals; the CTRL-[ version is more reliable there. |

**Only one of these should be enabled at a time** in Karabiner-Elements (they both remap the same key).

## Upstream

- **caps_lock-escape.json** matches the common “Tap Caps Lock for ESC or Hold for Control” rule (e.g. from Karabiner’s *Add predefined rule* or the standard import format).
- **caps_lock-ctrl-bracket.json** is a custom variant that sends Ctrl+[ instead of Escape for better compatibility with Esc+key in zsh/terminals.

## Where Karabiner lives

- Config: `~/.config/karabiner/karabiner.json`
- Custom rules (imports): `~/.config/karabiner/assets/complex_modifications/`

Your active rules are in `karabiner.json` under `profiles[].complex_modifications.rules`. The JSON files in this folder are **backups** you can re-import or copy from; they are not auto-loaded by Karabiner.

## Toggling between the two

1. **In the UI:** Karabiner-Elements → Complex Modifications. Enable the rule you want (e.g. “Tap Caps Lock for CTRL-[…]”) and disable the other (“Tap Caps Lock for ESC…”).
2. **By editing config:** In `~/.config/karabiner/karabiner.json`, find the two rules by `description`. Set `"enabled": true` on the one you want and `"enabled": false` on the other, then save (Karabiner reloads automatically).

## Restoring from these files

- **Re-import:** In Karabiner-Elements → Complex Modifications → *Add your own rule* → *Import*, choose one of the JSON files. Then enable that rule and disable the other as above.
- **Copy into karabiner.json:** Copy the `manipulators` block from the chosen file’s `rules[0]` into `profiles[].complex_modifications.rules` in `karabiner.json`, and set `enabled` as desired.
