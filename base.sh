#! /usr/bin/zsh
source $(dirname $0)/_lib.sh

context 'Ensuring XDG directories exist'
run mkdir -p $XDG_CONFIG_HOME
run mkdir -p $XDG_CACHE_HOME
run mkdir -p $XDG_DATA_HOME
run mkdir -p $XDG_STATE_HOME

context 'Symlinking config files'
run ln -s $XDG_DATA_HOME/dotfiles/.config/* $HOME/.config/
run "rm $HOME/.bashrc > /dev/null; ln -s $XDG_DATA_HOME/dotfiles/.bashrc $HOME/"
run "rm $HOME/.zshrc > /dev/null; ln -s $XDG_DATA_HOME/dotfiles/.zshrc $HOME/"

context 'Creating prerequisite directories'
run mkdir -p $HOME/ws
run mkdir -p $XDG_STATE_HOME/bash # for bash_history
run mkdir -p $XDG_STATE_HOME/zsh  # for zsh_history
run touch $XDG_CONFIG_HOME/localrc

context 'Installing packages'
if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
    run sudo dnf update -y
    run sudo dnf install -y curl git neovim fd-find
elif rg --quiet 'Ubuntu|Debian' /etc/os-release; then
    run sudo apt update
    run sudo apt upgrade -y
    run sudo apt install -y curl git neovim fd-find
fi

context 'Uninstalling cockpit'
if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
    sudo systemctl stop cockpit
    sudo systemctl disable cockpit
    sudo dnf remove cockpit
fi

context 'Enabling automatic updates'
if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
    run sudo dnf install -y dnf-automatic
    run sudo sed -i \'s/apply_updates = no/apply_updates = yes/\' /etc/dnf/automatic.conf
    run sudo systemctl enable --now dnf-automatic.timer
elif rg --quiet 'Ubuntu|Debian' /etc/os-release; then
    sudo apt install unattended-upgrades
    sudo dpkg-reconfigure --priority=low unattended-upgrades
fi
