#!/bin/sh
DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$HOME/.config"

# Install tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
if [ "$(uname -s)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
  ln -sf "$DOTFILES_ROOT/terminal/ghostty.config.symlink" \
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
fi
