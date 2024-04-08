#! /usr/bin/zsh

ORANGE='\033[0;33m'
CYAN='\033[0;36m'
GREEN_BOLD='\033[1;32m'
NC='\033[0m'
function context() {
    echo "\n${ORANGE}${@:1}${NC}"
}
function message() {
    echo "${ORANGE}${@:1}${NC}"
}
function run() {
    (echo "${CYAN}${@:1}${NC}") >&2
    eval ${@:1}
}
function prompt() {
    echo -n "${GREEN_BOLD}${@:1}${NC}" >&2
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

# https://mise.jdx.dev/getting-started.html
context 'Installing mise-en-place'
if grep -q "Fedora" /etc/os-release; then
    run dnf install -y dnf-plugins-core
    run dnf config-manager --add-repo https://mise.jdx.dev/rpm/mise.repo
    run dnf install -y mise
elif grep -q "Ubuntu" /etc/os-release; then
    run apt update -y && apt install -y gpg sudo wget curl
    run sudo install -dm 755 /etc/apt/keyrings
    run wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
    run echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    run sudo apt update
    run sudo apt install -y mise
fi

context 'Installing Python'
if ! mise current python ; then
    # python build dependencies (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
    context 'Installing python build dependencies'
    if grep -q "Fedora" /etc/os-release; then
        run sudo dnf install -y make gcc zlib-devel bzip2 bzip2-devel \
            readline-devel sqlite sqlite-devel \
            openssl-devel tk-devel libffi-devel xz-devel
    elif grep -q "Ubuntu" /etc/os-release; then
        run sudo apt install -y make build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    else
        message "Installing python build dependencies failed"
    fi
    context 'Installing python with mise'
    run mise use -g python@3.11
else
    message 'Python detected. No need to install.'
fi

context 'Installing NodeJS'
if ! mise current node ; then
    # nodejs build dependencies (https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms)
    context 'Installing nodejs build dependencies'
    if grep -q "Fedora" /etc/os-release; then
        run sudo dnf install -y python3 gcc-c++ make python3-pip
    elif grep -q "Ubuntu" /etc/os-release; then
        run sudo apt install -y python3 g++ make python3-pip
    else
        message "Installing nodejs build dependencies failed"
    fi
    context 'Installing nodejs with mise'
    run mise use -g node@lts
else
    message 'NodeJS detected. No need to install.'
fi

context 'Installing shell customizations: oh-my-zsh and powerlevel10k'
# https://github.com/ohmyzsh/ohmyzsh#advanced-installation
run git clone https://github.com/ohmyzsh/ohmyzsh.git $XDG_DATA_HOME/oh-my-zsh
# https://github.com/romkatv/powerlevel10k#oh-my-zsh
run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $XDG_DATA_HOME/oh-my-zsh/custom/themes/powerlevel10k

context 'Installing tmux customizations: tpm'
message 'Run <prefix>-I in tmux to install plugins!'
run git clone https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm

context 'Installing language-specific neovim packages'
run pip3 install pynvim
run npm install -g neovim

# context 'Installing font: UbuntuMono Nerd Font'
# if grep -q "Ubuntu" /etc/os-release; then
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
