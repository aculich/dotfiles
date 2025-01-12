#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

# Symlink dotfiles
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# Set ZSH_CUSTOM to ~/.config/zsh
if ! grep -q "export ZSH_CUSTOM" "$HOME/.zshrc"; then
  echo 'export ZSH_CUSTOM=$HOME/.config/zsh' >> "$HOME/.zshrc"
fi

# Ensure oh-my-zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ln -sf "$DOTFILES_DIR/zsh/aliases.zsh" "$HOME/.oh-my-zsh/custom/aliases.zsh"

