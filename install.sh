#!/usr/bin/env bash
set -euo pipefail

# Dotfiles install script — runs automatically in devcontainers
# when VS Code/Cursor has dotfiles.repository configured.

# Install zsh if not present
if ! command -v zsh >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y zsh
  elif command -v apk >/dev/null 2>&1; then
    sudo apk add zsh
  fi
fi

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Link dotfiles
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

for file in .zshrc .gitconfig; do
  if [ -f "$DOTFILES_DIR/$file" ]; then
    ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
  fi
done

# Set zsh as default shell if possible
if command -v chsh >/dev/null 2>&1 && command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)" 2>/dev/null || true
fi

echo "[dotfiles] installed"
