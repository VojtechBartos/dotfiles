if filereadable(expand('~/.vimrc'))
  source ~/.vimrc
else
  source ~/.dotfiles/vim/vimrc.symlink
endif
