#!/usr/bin/env bash
# Common login defaults. Runs for the person and for every team* login.
# Scope: keys every account on this team wants and nobody argues about.
# Dock, Finder, tiling, hot corners are PERSONAL (dotfiles-private) or an
# explicit org exception (RRID Chrome-only). Karabiner never maps Caps Lock in
# any team file: this ByHost mapping is the one writer.
# Idempotent; chezmoi re-runs it only when this file changes.
set -euo pipefail

log() { printf '10-macos-defaults: %s\n' "$*"; }

# --- Caps Lock -> Control (ByHost, per keyboard VendorID-ProductID) ---------
CAPS_SRC=30064771129
CTRL_DST=30064771296
mapping="<dict><key>HIDKeyboardModifierMappingSrc</key><integer>${CAPS_SRC}</integer><key>HIDKeyboardModifierMappingDst</key><integer>${CTRL_DST}</integer></dict>"

keyboard_ids() {
  {
    ioreg -r -c AppleHIDKeyboardEventDriverV2 2>/dev/null
    ioreg -r -c IOHIDKeyboard 2>/dev/null
  } | awk '
    /"VendorID"/  { gsub(/[^0-9]/, "", $NF); v=$NF }
    /"ProductID"/ { gsub(/[^0-9]/, "", $NF); if (v != "") { print v "-" $NF; v="" } }
  '
  /usr/bin/hidutil list --matching '{"PrimaryUsagePage":1,"PrimaryUsage":6}' 2>/dev/null \
    | awk 'NR>2 && $1 ~ /^0x/ && $4=="1" && $5=="6" { print $1, $2 }' \
    | while read -r vid pid; do
        echo "$((vid))-$((pid))"
      done
}

n=0
while IFS= read -r id; do
  [[ -n "$id" ]] || continue
  n=$((n + 1))
  defaults -currentHost write -g "com.apple.keyboard.modifiermapping.${id}-0" -array "$mapping"
done < <(keyboard_ids | sort -u)
if (( n == 0 )); then
  defaults -currentHost write -g "com.apple.keyboard.modifiermapping.0-0-0" -array "$mapping"
  log "no keyboard IDs enumerated; wrote fallback 0-0-0"
else
  log "Caps Lock -> Control on $n keyboard(s)"
fi

# --- typing ----------------------------------------------------------------
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# --- files and panels ------------------------------------------------------
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- GNU parallel citation nag (parallel ships in wave 1) -------------------
mkdir -p "$HOME/.parallel" && touch "$HOME/.parallel/will-cite"

log "done (typing, extensions, panels, save-to-disk, will-cite). Log out/in for Caps Lock to match the GUI."
