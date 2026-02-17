#!/bin/sh

export ZSH=$HOME/.dotfiles

# Symlink Ghostty config on macOS so terminal colors/themes are consistent
if [ "$(uname -s)" = "Darwin" ]; then
  GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  DOTFILES_TERMINAL="$(cd "$(dirname "$0")" && pwd)"
  if [ -f "$DOTFILES_TERMINAL/ghostty.config" ]; then
    mkdir -p "$GHOSTTY_DIR"
    ln -sf "$DOTFILES_TERMINAL/ghostty.config" "$GHOSTTY_DIR/config"
  fi
fi
