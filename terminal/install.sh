#!/bin/sh
# Create directories needed for terminal config symlinks (bootstrap does the linking)
mkdir -p "$HOME/.config"
if [ "$(uname -s)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
fi
