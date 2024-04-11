#! /usr/bin/zsh

ORANGE='\e[0;33m'
CYAN='\e[0;36m'
CYAN_ITALIC='\e[3;36m'
GREEN_BOLD='\e[1;32m'
NC='\e[0m'
function context() {
    echo "\n$ORANGE${@:1}$NC"
}
function message() {
    echo "$ORANGE${@:1}$NC"
}
function run_noeval() {
    echo "$CYAN${@:1}$NC"
}
function run() {
    echo "$CYAN${@:1}$NC"
    eval ${@:1}
}
function prompt() {
    echo -n "$GREEN_BOLD$1$NC"
    read -e response
}
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
function unique_append() {
    read -r -d '' MSG
    rg --quiet --fixed-strings --multiline $MSG $1 || echo "$MSG\n" >> $1
}

context 'Ensuring XDG directories exist'
run mkdir -p $XDG_CONFIG_HOME
run mkdir -p $XDG_CACHE_HOME
run mkdir -p $XDG_DATA_HOME
run mkdir -p $XDG_STATE_HOME

context 'Installing packages'
if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
    run sudo dnf update -y
    run sudo dnf install -y curl git tmux neovim fd-find
elif rg --quiet 'Ubuntu|Debian' /etc/os-release; then
    run sudo apt update
    run sudo apt upgrade -y
    run sudo apt install -y curl git tmux neovim fd-find
fi

context 'Uninstalling cockpit'
if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
    sudo systemctl stop cockpit
    sudo systemctl disable cockpit
    sudo dnf remove cockpit
fi

# # Set default shell to ZSH
# context 'Changing default shell to zsh'
# if command -v lchsh &> /dev/null; then
#     run sudo lchsh $USER  # set to /usr/bin/zsh
# elif command -v chsh &> /dev/null; then
#     run chsh -s $(which zsh)
# else
#     message "Warning: default shell could not be changed to zsh."
# fi

context 'Enabling automatic updates'
if rg --quiet 'Fedora|Red Hat' /etc/os-release; then
    run sudo dnf install -y dnf-automatic
    run sudo sed -i \'s/apply_updates = no/apply_updates = yes/\' /etc/dnf/automatic.conf
    run sudo systemctl enable --now dnf-automatic.timer
elif rg --quiet 'Ubuntu|Debian' /etc/os-release; then
    sudo apt install unattended-upgrades
    sudo dpkg-reconfigure --priority=low unattended-upgrades
fi

# Remove old config files
# context 'Removing old config files'
# run rm -rf ~/.zshrc ~/.tmux.conf ~/.config/tmux ~/.profile ~/.p10k.zsh ~/.config/alacritty ~/.config/i3 ~/.config/nvim ~/.config/polybar ~/.config/powerlevel10k ~/.config/sway ~/.config/waybar ~/.asdf ~/.config/dotfiles
context 'Creating prerequisite directories'
run mkdir -p $HOME/ws
run mkdir -p $XDG_STATE_HOME/zsh  # for zsh_history
DOTFILES="$XDG_DATA_HOME/dotfiles"

context 'Installing dotfiles'
run mkdir -p $HOME/ws
run git clone https://github.com/QuocAnhVu/dotfiles.git $DOTFILES
context 'Symlinking config files'
run ln -s $DOTFILES/.config/* $HOME/.config/
run ln -s $DOTFILES/.zshrc $HOME/
run ln -s $DOTFILES/.profile $HOME/
run touch $XDG_CONFIG_HOME/localrc

context 'Installing shell customizations: oh-my-zsh and powerlevel10k'
# https://github.com/ohmyzsh/ohmyzsh#advanced-installation
run git clone https://github.com/ohmyzsh/ohmyzsh.git $XDG_DATA_HOME/oh-my-zsh
# https://github.com/romkatv/powerlevel10k#oh-my-zsh
run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $XDG_DATA_HOME/oh-my-zsh/custom/themes/powerlevel10k

context 'Installing tmux customizations: tpm'
message 'Run <prefix>-I in tmux to install plugins!'
run git clone https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm

# context 'Installing font: UbuntuMono Nerd Font'
# if rg --quiet 'Ubuntu|Debian' /etc/os-release; then
#     run sudo apt install -y fontconfig
# fi
# if ! fc-list | grep 'UbuntuMono Nerd Font' > /dev/null ; then
#     # https://github.com/ryanoasis/nerd-fonts#option-6-ad-hoc-curl-download
#     run git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git $XDG_CACHE_HOME/nerd-fonts
#     # https://github.com/ryanoasis/nerd-fonts#option-3-install-script
#     run pushd $XDG_CACHE_HOME/nerd-fonts
#     run git sparse-checkout add patched-fonts/UbuntuMono
#     run ./install.sh UbuntuMono
#     run popd
#     run rm -rf $XDG_CACHE_HOME/nerd-fonts
# else
#     message 'UbuntuMono Nerd Font detected - no installation needed.'
# fi
