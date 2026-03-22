# ~/.zshrc snapshots

Use this directory to capture the **live** `~/.zshrc` before editing, so installer-appended blocks (conda, tools, etc.) are not lost and you can reconcile with the repo.

## Commands

From the dotfiles repo:

```bash
~/dotfiles/scripts/snapshot-zshrc              # copy ~/.zshrc to zsh/snapshots/.zshrc.<timestamp>
~/dotfiles/scripts/snapshot-zshrc --diff       # diff ~/.zshrc vs canonical (default: zsh/.zshrc.professional)
~/dotfiles/scripts/snapshot-zshrc --both       # copy, then diff
```

Override paths if needed:

```bash
ZSHRC_CANONICAL=~/dotfiles/zsh/.zshrc HOME_ZSHRC=~/.zshrc ~/dotfiles/scripts/snapshot-zshrc --diff
```

## Workflow

1. Run `snapshot-zshrc` (or `--both`) before changing dotfiles or running installers that edit `~/.zshrc`.
2. Edit the **canonical** file in `~/dotfiles/zsh/` (see `bootstrap.sh` for which file is linked to `~/.zshrc`).
3. Merge any unique lines from the snapshot into the canonical file, bump the `Last updated` header, commit.

Snapshot files are gitignored; only this README is tracked.
