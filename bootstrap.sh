#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

# Canonical interactive zshrc (professional profile; short alternative: zsh/.zshrc)
ln -sf "$DOTFILES_DIR/zsh/.zshrc.professional" "$HOME/.zshrc"

# Set ZSH_CUSTOM to ~/.config/zsh
if ! grep -q "export ZSH_CUSTOM" "$HOME/.zshrc"; then
  echo 'export ZSH_CUSTOM=$HOME/.config/zsh' >> "$HOME/.zshrc"
fi

# Ensure oh-my-zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ZSH_CUSTOM defaults to ~/.config/zsh (see zsh/.zshrc or .zshrc.professional); OMZ loads custom files from there
mkdir -p "$HOME/.config/zsh"
ln -sf "$DOTFILES_DIR/zsh/aliases.zsh" "$HOME/.config/zsh/aliases.zsh"
# Legacy path: harmless if unused; some setups still expect it
ln -sf "$DOTFILES_DIR/zsh/aliases.zsh" "$HOME/.oh-my-zsh/custom/aliases.zsh"

