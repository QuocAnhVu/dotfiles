#! /usr/bin/sh

bash -ci "$(curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/preinstall.sh)"
zsh -c "$(curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/install.sh)"
cd ~/.local/share/dotfiles
./harden_ssh.sh