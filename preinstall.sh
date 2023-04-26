#! /usr/bin/bash

if command -v apt &> /dev/null; then
    PKG=apt
elif command -v dnf &> /dev/null; then
    PKG=dnf
else
    echo "Distro's package manager is not supported."
    exit
fi

sudo $PKG update
sudo $PKG install -y curl git zsh tmux neovim ripgrep
/usr/bin/pip3 install neovim

# python build dependencies (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
if command -v apt &> /dev/null; then
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
elif command -v dnf &> /dev/null; then
    sudo dnf install -y make gcc zlib-devel bzip2 bzip2-devel \
        readline-devel sqlite sqlite-devel \
        openssl-devel tk-devel libffi-devel xz-devel
else
    echo "Distro's package manager is not supported."
    exit
fi

# nodejs build dependencies (https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms)
if command -v apt &> /dev/null; then
    sudo apt install -y python3 g++ make python3-pip
elif command -v dnf &> /dev/null; then
    sudo dnf install -y python3 gcc-c++ make python3-pip
else
    echo "Distro's package manager is not supported."
    exit
fi

# window managers: i3/sway + polybar/waybar
#sudo $PKG install -y i3 polybar sway waybar

# Set default shell to ZSH
if command -v chsh &> /dev/null; then
    sudo chsh -s $(which zsh)
elif command -v lchsh &> /dev/null; then
    sudo lchsh $USER  # set to /usr/bin/zsh
else
    echo "Warning: default shell could not be changed to zsh."
fi

# Ubuntu specific
if command -v chsh &> /dev/null; then
    sudo apt install -y fontconfig
fi

# Remove old config files
rm -rf ~/.zshrc ~/.tmux.conf ~/.config/tmux ~/.profile ~/.p10k.zsh ~/.config/alacritty ~/.config/i3 ~/.config/nvim ~/.config/polybar ~/.config/powerlevel10k ~/.config/sway ~/.config/waybar ~/.asdf ~/.config/dotfiles
