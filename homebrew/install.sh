#!/bin/sh
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."

  # Install the correct homebrew for each OS type
  if test "$(uname)" = "Darwin"
  then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
  then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
  fi

fi

function install() {
  app=$1
  cask=${2:-}

cat << EOF

-> Installing ${app}...
EOF

  if [[ x"$OS" == x"Windows" ]]; then
    scoop install ${app}
  else
    if [[ ! "$cask" ]]; then
      brew list ${app} >/dev/null || brew install ${app}
    else
      brew list ${app} --cask >/dev/null || brew install ${app} --cask
    fi
  fi

cat << EOF

-> ${app} installed
EOF
}

install 1password yes
install alfred yes
install bartender yes
install brave-browser yes
install caffeine yes
install claude-code yes
install claude yes
install cmake
install cowsay
install cursor yes
install dropbox yes
install fzf
install fnm
install flycut yes
install fork yes
install fortune
install gh
install ghostty yes
install git-lfs
install go
install gnupg
install google-chrome yes
# install google-drive yes
install gopls    # Go LSP
install gping
install grip # for markdown preview
install htop
install httpie
install istat-menus
install jq
install lazygit
install lazygit
install markdownlint-cli2
install mergiraf
install neovim
install ngrok yes
install openssl
install orbstack yes
install postman yes
install pyright  # Python LSP for Neovim
install readline
install reattach-to-user-namespace
install rectangle yes
install rbenv
install ruby-install
install secretive yes
install slack yes
install spotify yes
install sqlite3
install starship
install superhuman yes
install the_silver_searcher  # vim ag search
install tmux
install typescript-language-server  # TypeScript/React LSP
install tree-sitter
install uv
install visual-studio-code yes
install whatsapp yes
install wget
install xz
install zlib
install zsh
install zsh-autosuggestions
install zsh-syntax-highlighting

# Git large files
git lfs install

# Bontree (check out if hombrew is in place to replace installs
go install github.com/almonk/bontree@latest

# Ruby 3.1.3 via ruby-install (uses Homebrew openssl; openssl@1.1 is deprecated)
# export PATH="/opt/homebrew/opt/openssl/bin:$PATH"
# export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl/lib/pkgconfig:$PKG_CONFIG_PATH"
# export LDFLAGS="-L/opt/homebrew/opt/openssl/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/openssl/include"
RUBY_DIR="$HOME/.rubies/ruby-3.1.3"
if [ ! -x "$RUBY_DIR/bin/ruby" ]; then
  ruby-install ruby 3.1.3
fi
if [ -x "$RUBY_DIR/bin/gem" ]; then
  "$RUBY_DIR/bin/gem" install kamal
fi

brew cleanup
rm -f -r /Library/Caches/Homebrew/*

exit 0
