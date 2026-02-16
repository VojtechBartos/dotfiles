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
install brave-browser yes
install cursor yes
install fnm
install fortune
install cowsay
install ghostty yes
install caffeine yes
install claude-code yes
install superhuman yes
install orbstack yes
install uv
install lazygit
install neovim
install fork yes
install flycut yes
install alfred yes
install rectangle yes
install google-chrome yes
install bartender yes
install gh
install go
install lazygit
install google-drive yes
install markdownlint-cli2
install mergiraf
install ngrok yes
install openssl
install postman yes
install readline
install secretive yes
install slack yes
install spotify yes
install sqlite3
install visual-studio-code yes
install xz
install zlib
install zsh
install fzf
install reattach-to-user-namespace
install pure # pure prompt for ohmyzsh theme
install grip # for markdown preview
install cmake
install tmux
install wget
install gnupg
install gping
install htop
install istat-menus
install whatsapp yes
install the_silver_searcher  # vim ag search



brew cleanup
rm -f -r /Library/Caches/Homebrew/*

exit 0
