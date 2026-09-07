# Public patterns vs private data

Keeping [aculich/dotfiles](https://github.com/aculich/dotfiles) **private** is a good default so a mistaken `git add` does not publish a machine. Other people *do* publish dotfiles safely; the trick is **never putting secrets in git in any form you would regret pasting on a billboard**. Encryption in git is a last resort, not a substitute for 1Password.

macos-reinstall already follows this for licenses: keys in 1Password, [licenses/INDEX.md](https://github.com/aculich/macos-reinstall/blob/main/licenses/INDEX.md) is titles + `op://` only ([docs/SECRETS.md](https://github.com/aculich/macos-reinstall/blob/main/docs/SECRETS.md)).

## Three buckets

| Bucket | Examples | Where it lives |
|--------|----------|----------------|
| **Shareable pattern** | Starship.toml, Sheldon plugins, zsh aliases with no hostnames, `brew` names, chezmoi *templates* | Git, can be **public** later |
| **Personal, not a secret** | git name/email, hostname, Hardware UUID, “I use Linear” | chezmoi `[data]` from a **local** config / `promptStringOnce`; `~/.zshrc.local`; never a committed literal |
| **Secret / license / token** | API keys, Shottr/Contexts keys, age private key, `.env`, SSH keys, Raycast tokens | **1Password** (or Keychain). Chezmoi may *read* at apply time. Mackup store stays gitignored |

`private_` in chezmoi only sets file mode **0600**. It still **commits the contents**. Do not use it as “this is secret.”

## How public chezmoi repos stay safe

Official chezmoi: [1Password templates](https://www.chezmoi.io/user-guide/password-managers/1password/), [age encryption](https://www.chezmoi.io/user-guide/encryption/age/).

1. **Templates, not values.** Commit `dot_gitconfig.tmpl` with `{{ .email }}`, not `aaron@…`. Values come from `~/.config/chezmoi/chezmoi.toml` (outside the source repo) or 1Password.
2. **`onepasswordRead` at apply.** Example (not in this repo yet):

   ```
   {{ onepasswordRead "op://Personal/some-item/password" }}
   ```

   Git contains the **op:// path**, same idea as macos-reinstall’s INDEX. Apply needs `op` signed in (Touch ID is fine).
3. **Untracked locals.** `~/.zshrc.local`, `*.local` (already gitignored here).
4. **Second private source (optional).** Public `dotfiles` + private `dotfiles-private` (or chezmoi extra source). Patterns public; machine email, work VPN snippets private. We have not created the private overlay yet — this whole repo *is* the private overlay until a public split is worth it.
5. **age + SOPS / `chezmoi add --encrypt`.** Encrypted blobs *can* live in a public git. The **age private key** stays in 1Password (macos-reinstall already does this). Prefer 1Password for licenses and passwords; encrypt files only when you need a file in git (weird plist), not as a second copy of the Shottr key.
6. **Scanners.** gitleaks / detect-secrets / pre-commit (macos-reinstall `Brewfile.security`). Refuse `mackup-store/`, `.env`, keys.

Strap-shaped teams often keep **`username/dotfiles` private** and publish only a Brewfile of non-secret cask names. That is valid. Public is optional.

## macos-reinstall: already split, still personal

| In git (OK if repo stays private; review before public) | Never in git |
|----------------------------------------------------------|--------------|
| `apps/*/CUSTOM.md` windowing notes | License keys, `.contexts-license` |
| `licenses/INDEX.md` item **titles**, `op item get "Mac · Shottr · license"` | The key field |
| Public age **recipient** in `.sops.yaml` | Age **private** key (`op://Personal/Mac macos-reinstall age key`) |
| Brewfile cask names | `mackup-store/` |
| Redacted profiler JSON | Raw dumps with home paths / emails (strip or SOPS) |

INDEX still has purchase dates, Gmail thread ids, invoice ids. Those are **personal**, not software keys. Fine in a private repo; strip before any public fork.

## This repo’s rules (day one)

- Stay **private** until shareable `home/` files have no literals.
- No `.env`, history, SSH, op session, license files.
- Future gitconfig/ssh: templates + 1Password or local chezmoi data.
- Same path: not Mackup *and* chezmoi.
- Before `git add -A` on a pile of `~/.config`: `chezmoi add` by file, then `gitleaks detect`.

When we have a real `dot_zshrc`, we can revisit “public fork of patterns + this repo as private overlay.” Not required to use chezmoi.
