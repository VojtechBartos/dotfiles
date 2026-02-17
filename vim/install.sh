#!/bin/sh
# Symlink Neovim config (init.lua + lua/plugins) for lazy.nvim
DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NVIM_DIR="$HOME/.config/nvim"
mkdir -p "$NVIM_DIR"
mkdir -p "$NVIM_DIR/lua"

ln -sf "$DOTFILES_ROOT/vim/init.lua" "$NVIM_DIR/init.lua"
ln -sf "$DOTFILES_ROOT/vim/lua/plugins" "$NVIM_DIR/lua/plugins"
# Avoid conflicting configs: Neovim loads both init.lua and init.vim if both exist
rm -f "$NVIM_DIR/init.vim"

# Install plugins (lazy.nvim will sync on first nvim run, or run :Lazy sync)
if command -v nvim >/dev/null 2>&1; then
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
fi
