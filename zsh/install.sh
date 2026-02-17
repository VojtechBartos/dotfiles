if [ -f $HOME/.iterm2_shell_integration.zsh ]; then
    echo "iTerm2 shell integration already installed."
else
    echo "Installing iTerm2 shell integration..."
    curl -L https://iterm2.com/shell_integration/zsh -o $HOME/.iterm2_shell_integration.zsh
fi

git clone https://github.com/powerline/fonts.git ./powerline-fonts --depth=1
cd ./powerline-fonts
./install.sh
cd ..
rm -rf ./powerline-fonts