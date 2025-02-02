# Zsh Plugin Keybindings Documentation

This document provides a comprehensive overview of the keybindings for various Zsh plugins. Each section describes the keybindings for a specific plugin, what they do, and the module name you would use in your Zsh configuration. This guide is meant to help you understand and customize your terminal experience effectively.

## TheFuck Plugin (`plugins/thefuck/thefuck.plugin.zsh`)

### Description
TheFuck plugin corrects errors in previous console commands using the `fuck` command.

### Keybindings
- **`Esc Esc` (in `emacs`, `vicmd`, and `viins` modes):** Invokes the `fuck-command-line` function to correct the last command.

## DirHistory Plugin (`plugins/dirhistory/dirhistory.plugin.zsh`)

### Description
DirHistory allows users to navigate through a history of directories accessed, enhancing directory travel efficiency.

### Keybindings
- **Backward in History:**
  - `Alt + Left Arrow` (varies by terminal): Calls `dirhistory_zle_dirhistory_back`.
- **Forward in History:**
  - `Alt + Right Arrow` (varies by terminal): Calls `dirhistory_zle_dirhistory_future`.
- **Up in History:**
  - `Alt + Up Arrow` (varies by terminal): Calls `dirhistory_zle_dirhistory_up`.
- **Down in History:**
  - `Alt + Down Arrow` (varies by terminal): Calls `dirhistory_zle_dirhistory_down`.

## Fancy Ctrl+Z Plugin (`plugins/fancy-ctrl-z/fancy-ctrl-z.plugin.zsh`)

### Description
This plugin provides a fancy interface for suspending processes using `Ctrl+Z`.

### Keybindings
- **`Ctrl+Z`:** Triggers the `fancy-ctrl-z` function for a fancier process suspension.

## Man Plugin (`plugins/man/man.plugin.zsh`)

### Description
Enhances the `man` command functionality within Zsh.

### Keybindings
- **`Esc` + `man`:** Triggers the `man-command-line` function to access man pages.

## Per-Directory History Plugin (`plugins/per-directory-history/per-directory-history.zsh`)

### Description
Maintains a separate history for each directory, allowing users to toggle and access history based on the current directory.

### Keybindings
- **Custom Toggle (default unset):** Bound to `per-directory-history-toggle-history`.

## Colemak Layout Plugin (`plugins/colemak/colemak.plugin.zsh`)

### Description
Adapts Zsh keybindings for the Colemak keyboard layout, making navigation conform to the Colemak standard.

### Keybindings
- **Various key reassignments** to match typical Colemak usage, including accepting lines, moving through history, and character navigation.

## History Substring Search Plugin (`plugins/history-substring-search/history-substring-search.plugin.zsh`)

### Description
Enhances history searching capabilities in Zsh, allowing substring search.

### Keybindings
- **History Substring Search:**
  - `Up Arrow`: Triggers `history-substring-search-up`.
  - `Down Arrow`: Triggers `history-substring-search-down`.

## Zsh Interactive CD Plugin (`plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh`)

### Description
Provides an interactive interface for changing directories, enhancing the `cd` command.

### Keybindings
- **`Tab`:** Triggers `zic-completion`, allowing interactive directory selection.

## Globalias Plugin (`plugins/globalias/globalias.plugin.zsh`)

### Description
Allows global alias expansion with a space to simplify command input.

### Keybindings
- **`Space` (in `emacs` and `viins` modes):** Triggers the `globalias` or `magic-space` function for automatic alias expansion.

## FZF WD Plugin (`plugins/wd/README.md`)

### Description
Integrates fzf with the `wd` (warp directory) command for interactive directory jumping.

### Keybindings
- **`Ctrl+B`:** Invokes `wd_browse_widget` for fzf-based directory browsing.

## Zsh Navigation Tools (`plugins/zsh-navigation-tools/`)

### Description
Provides a set of tools for navigating and managing the Zsh environment more effectively.

### Keybindings
- **`Ctrl+R`:** Triggers `znt-history-widget`.
- **`Ctrl+B`:** Triggers `znt-cd-widget`.
- **`Ctrl+Y`:** Triggers `znt-kill-widget`.

## Vi Mode Plugin (`plugins/vi-mode/vi-mode.plugin.zsh`)

### Description
Enables and customizes `vi` mode within Zsh.

### Keybindings
- **`V` in `vicmd` mode:** Maps to `edit-command-line`.
- **Various `vi`-mode navigation and edit commands**, enhancing editing experience.

## Safe Paste Plugin (`plugins/safe-paste/safe-paste.plugin.zsh`)

### Description
Prevents accidental code execution from paste, enhances safety when pasting commands.

### Keybindings
- **Bracketed Paste Mode initiation and termination,** providing safe paste handling.

## Jump Plugin (`plugins/jump/jump.plugin.zsh`)

### Description
Simplifies moving around a directory structure, keeping marked locations.

### Keybindings
- **`Ctrl+G`:** Invokes `_mark_expansion` to expand mark locations.

## Percol Plugin (`plugins/percol/percol.plugin.zsh`)

### Description
Provides selection functionality from history and marks with fuzzy search, using Percol.

### Keybindings
- **`Ctrl+R`:** Activates `percol_select_history` for fuzzy search in history.
- **`Ctrl+B`:** Activates `percol_select_marks` for fuzzy search in marks.

## DirCycle Plugin (`plugins/dircycle/dircycle.plugin.zsh`)

### Description
Allows cycling through directories using keyboard shortcuts, making navigation efficient.

### Keybindings
- **`Ctrl+Shift+Arrow Keys`:** Navigate through directory cyclically, supporting left, right, up, and down directions.

## Term Tab Plugin (`plugins/term_tab/term_tab.plugin.zsh`)

### Description
Facilitates tab switching and management in terminal emulators supporting tabs.

### Keybindings
- **`Ctrl+V`:** Activates `term_list` to list and switch terminal tabs.

## Zsh Git FZF Plugin (`plugins/zsh-git-fzf/README.md`)

### Description
Integrates fzf with Git commands, allowing interactive Git operations.

### Keybindings
- **`Ctrl+O`:** `git-fzf checkout`.
- **`Ctrl+L`:** `git-fzf log`.
- **`Ctrl+D`:** `git-fzf diff`.

## Sudo Plugin (`plugins/sudo/sudo.plugin.zsh`)

### Description
Offers a convenient way to re-run commands with `sudo`.

### Keybindings
- **`Esc Esc`:** Re-applies `sudo` to the previous command for elevated permissions.

## TLDR Plugin (`plugins/tldr/tldr.plugin.zsh`)

### Description
Fetches and displays TLDR cheat sheets for quick command syntax reference.

### Keybindings
- **`Esc` + `tldr`:** Activates `tldr-command-line` to view TLDR pages.

## NPM Plugin (`plugins/npm/npm.plugin.zsh`)

### Description
Adds shortcuts for frequently used NPM commands to toggle install/uninstall modes.

### Keybindings
- **Hyper-Key Sequence (default):** Binds to `npm_toggle_install_uninstall`.

## Shrink Path Plugin (`plugins/shrink-path/README.md`)

### Description
Shrinks a file path, showing a shortened representation with `..` for parent directories.

### Keybindings
- **`Alt+Shift+S`:** Activates `shrink-path-toggle`.

This comprehensive guide should help you in configuring and understanding the various input bindings for plugins integrated into your Zsh environment, enhancing both usability and efficiency.
