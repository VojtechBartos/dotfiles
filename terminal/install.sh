#!/bin/sh
DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$HOME/.config"
if [ "$(uname -s)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
  ln -sf "$DOTFILES_ROOT/terminal/ghostty.config.symlink" \
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
fi
