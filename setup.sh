#!/usr/bin/env bash

echo "Starting dotfiles setup..."

# Install Homebrew (if not already installed)
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install tools with Homebrew
echo "Installing Homebrew tools..."
brew install tree
brew install fzf
brew install git

# Clone and install gcop from GitHub
GCOP_DIR="$HOME/tools/gcop"
if [ ! -d "$GCOP_DIR" ]; then
    echo "Installing gcop from GitHub..."
    mkdir -p "$HOME/tools"
    git clone https://github.com/Undertone0809/gcop.git "$GCOP_DIR"
    (cd "$GCOP_DIR" && make install)  # Update if gcop has specific installation steps
else
    echo "gcop is already installed at $GCOP_DIR"
fi

# Add ~/.local/bin to PATH if not already present
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
fi

# Reload shell
echo "Reloading shell..."
exec "$SHELL"
echo "Setup complete!"
