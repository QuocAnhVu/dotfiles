#! /usr/bin/bash
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
function context() {
    echo "\n${ORANGE}${@:1}${NC}"
}
function message() {
    echo "${ORANGE}${@:1}${NC}"
}
function run() {
    echo "${CYAN}${@:1}${NC}"
    eval ${@:1}
}
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
run mkdir -p $XDG_CONFIG_HOME
run mkdir -p $XDG_CACHE_HOME
run mkdir -p $XDG_DATA_HOME
run mkdir -p $XDG_STATE_HOME

if command -v apt &> /dev/null; then
    PKG=apt
elif command -v dnf &> /dev/null; then
    PKG=dnf
else
    message "Distro's package manager is not supported."
    exit
fi

context 'Installing packages'
run sudo $PKG update
run sudo $PKG install -y curl git zsh tmux neovim ripgrep
run /usr/bin/pip3 install neovim

# python build dependencies (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
context 'Installing python build dependencies'
if command -v apt &> /dev/null; then
    run sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
elif command -v dnf &> /dev/null; then
    run sudo dnf install -y make gcc zlib-devel bzip2 bzip2-devel \
        readline-devel sqlite sqlite-devel \
        openssl-devel tk-devel libffi-devel xz-devel
else
    message "Installing python build dependencies failed"
fi

# nodejs build dependencies (https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms)
context 'Installing nodejs build dependencies'
if command -v apt &> /dev/null; then
    run sudo apt install -y python3 g++ make python3-pip
elif command -v dnf &> /dev/null; then
    run sudo dnf install -y python3 gcc-c++ make python3-pip
else
    message "Installing nodejs build dependencies failed"
fi

# window managers: i3/sway + polybar/waybar
#sudo $PKG install -y i3 polybar sway waybar

# Set default shell to ZSH
context 'Changing default shell to zsh'
if command -v chsh &> /dev/null; then
    run sudo chsh -s $(which zsh)
elif command -v lchsh &> /dev/null; then
    run sudo lchsh $USER  # set to /usr/bin/zsh
else
    message "Warning: default shell could not be changed to zsh."
fi

# Ubuntu specific
if command -v chsh &> /dev/null; then
    context ' Installing Ubuntu specific packages'
    run sudo apt install -y fontconfig
fi

# Remove old config files
context 'Removing old config files'
run rm -rf ~/.zshrc ~/.tmux.conf ~/.config/tmux ~/.profile ~/.p10k.zsh ~/.config/alacritty ~/.config/i3 ~/.config/nvim ~/.config/polybar ~/.config/powerlevel10k ~/.config/sway ~/.config/waybar ~/.asdf ~/.config/dotfiles
