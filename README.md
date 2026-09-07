# aculich/dotfiles

Private **chezmoi** source for desired text configs (`$HOME`). Almost a green field: zsh is **not** copied from the old tree.

Predecessor (do not apply): [aculich/dotfiles-pre20260906](https://github.com/aculich/dotfiles-pre20260906). What we scanned there: [docs/LEGACY.md](docs/LEGACY.md).

This is **not** a Brewfile and **not** macos-reinstall. Strap will look for `script/setup` here after brew exists.

## Who writes what

| Job | Tool | This repo? |
|-----|------|------------|
| Install apps and CLI bottles | Homebrew Bundle (`brew bundle --file`) + [macos-reinstall](https://github.com/aculich/macos-reinstall) overlay | No (packages live next door) |
| Desired **text** in `$HOME` (zsh, Starship, git, sheldon, mise.toml, Cursor/agent snippets) | **chezmoi** | **Yes** |
| Capture **binary app prefs** (plists, GUI state) | Mackup **copy** mode in macos-reinstall (`mackup-store/` gitignored) | Observe there; **re-derive** keepers into chezmoi or `apps/*/CUSTOM.md` — do not Mackup-restore as source of truth |
| Bit-for-bit disaster | Time Machine / restic | No |
| Secrets | 1Password (`op`); chezmoi `onepasswordRead` at apply | Never commit keys; see [docs/SHARING.md](docs/SHARING.md) |

Keeping the GitHub repo **private** is belt-and-suspenders so a sloppy add cannot leak. Shareable **patterns** (Starship, aliases, templates with `{{ .email }}`) can go public later; **values** (email, keys, licenses) stay in 1Password or local chezmoi data. `private_` in chezmoi is only chmod 600 — it still commits the file.

macos-reinstall already puts Shottr/Contexts/Raycast keys in 1Password and gitignores `mackup-store/`. Same rule here.

Mackup **link** mode breaks prefs on Sonoma+. macos-reinstall already uses copy mode. Workflow: backup → read the plist/json → write a small declarative file here (or a `defaults` snippet) → `chezmoi apply`. Same path must not be owned by both Mackup and chezmoi.

chezmoi **applies** generated files (replace), it does not “restore a blob dump.” That is the point.

## Layout

```
.chezmoiroot          # chezmoi source is home/
home/                 # maps to $HOME (dot_zshrc → ~/.zshrc, later)
script/setup          # Strap hook: chezmoi init --apply
script/strap-after-setup
docs/LEGACY.md
```

Zsh/Starship/Sheldon land in `home/` in a later commit (scenario A: OMZ as plugin catalog, not the old `.zshrc.professional` + OMZ snapshots).

Machine-local overrides: `~/.zshrc.local` (ignored). Never commit `history.list` or `.env*`.

## Apply

```bash
brew install chezmoi   # if needed
chezmoi init --apply git@github.com:aculich/dotfiles.git
# or, from a clone:
./script/setup
```

Strap: clone this repo as `username/dotfiles` and run `script/setup`.
