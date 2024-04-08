#! /usr/bin/bash
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
GREEN_BOLD='\033[1;32m'
NC='\033[0m'
function context() {
    echo -e "\n${ORANGE}${@:1}${NC}"
}
function message() {
    echo -e "${ORANGE}${@:1}${NC}"
}
function run() {
    (echo -e "${CYAN}${@:1}${NC}") >&2
    eval ${@:1}
}
function prompt() {
    echo -e -n "${GREEN_BOLD}${@:1}${NC}" >&2
    read response
    echo "$response"
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
if grep -q "Fedora" /etc/os-release; then
    run sudo dnf install -y curl git zsh tmux neovim ripgrep fd-find
elif grep -q "Ubuntu" /etc/os-release; then
    run sudo apt install -y curl git zsh tmux neovim ripgrep fd-find
fi

# window managers: i3/sway + polybar/waybar
#sudo $PKG install -y i3 polybar sway waybar

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
if grep -q "Fedora" /etc/os-release; then
    run sudo dnf install -y dnf-automatic
    run sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
    run sudo systemctl enable --now dnf-automatic.timer
elif grep -q "Ubuntu" /etc/os-release; then
    sudo apt install unattended-upgrades
    sudo dpkg-reconfigure --priority=low unattended-upgrades

# Remove old config files
context 'Removing old config files'
run rm -rf ~/.zshrc ~/.tmux.conf ~/.config/tmux ~/.profile ~/.p10k.zsh ~/.config/alacritty ~/.config/i3 ~/.config/nvim ~/.config/polybar ~/.config/powerlevel10k ~/.config/sway ~/.config/waybar ~/.asdf ~/.config/dotfiles
