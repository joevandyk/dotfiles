#!/usr/bin/env bash
set -euo pipefail

# Dotfiles install script
# Usage: ./install.sh
# Also runs automatically in devcontainers when VS Code/Cursor
# has dotfiles.repository configured.

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# Symlink dotfiles
for file in .zshrc .zshenv .gitconfig .tmux.conf; do
  if [ -f "$DOTFILES_DIR/$file" ]; then
    ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    echo "[dotfiles] linked $file"
  fi
done

# Symlink Claude config files
mkdir -p "$HOME/.claude"
for file in settings.json .mcp.json CLAUDE.md; do
  if [ -f "$DOTFILES_DIR/.claude/$file" ]; then
    ln -sf "$DOTFILES_DIR/.claude/$file" "$HOME/.claude/$file"
    echo "[dotfiles] linked .claude/$file"
  fi
done

# Set zsh as default shell if possible
if command -v chsh >/dev/null 2>&1 && command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)" 2>/dev/null || true
fi

echo "[dotfiles] installed"
