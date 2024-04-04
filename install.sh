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

# https://asdf-vm.com/guide/getting-started.html
context 'Installing asdf, nodejs, python'
run git clone https://github.com/asdf-vm/asdf.git $XDG_DATA_HOME/asdf --branch v0.14.0
run source ~/.zshrc
# https://github.com/danhper/asdf-python
if ! asdf current python ; then
    run asdf plugin-add python
    run asdf install python latest
    run asdf global python latest
else
    message 'asdf python detected - no installation needed.'
fi
# https://github.com/asdf-vm/asdf-nodejs
if ! asdf current nodejs ; then
    run asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    run asdf install nodejs latest
    run asdf global nodejs latest
else
    message 'asdf nodejs detected - no installation needed.' 
fi

context 'Installing shell customizations: oh-my-zsh and powerlevel10k'
# https://github.com/ohmyzsh/ohmyzsh#advanced-installation
run git clone https://github.com/ohmyzsh/ohmyzsh.git $XDG_DATA_HOME/oh-my-zsh
# https://github.com/romkatv/powerlevel10k#oh-my-zsh
run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $XDG_DATA_HOME/oh-my-zsh/custom/themes/powerlevel10k

context 'Installing tmux customizations: tpm'
message 'Run <prefix>-I in tmux to install plugins!'
run "git clone https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm"

context 'Installing language-specific neovim packages'
run "pip3 install pynvim"
run "npm install -g neovim"

# context 'Installing font: UbuntuMono Nerd Font'
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
