#! /bin/zsh

ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
function context() {
    echo "\n${ORANGE}${1}${NC}"
}
function run() {
    echo "${CYAN}${1}${NC}"
    eval $1
}

run 'mkdir -p $HOME/.config'

context 'Installing dotfiles'
run 'git clone https://github.com/QuocAnhVu/dotfiles.git $HOME/.config/dotfiles'
context 'Symlinking config files'
run 'ln -s $HOME/.config/dotfiles/.config/* $HOME/.config/'
run 'ln -s $HOME/.config/dotfiles/.tmux.conf $HOME/.config/dotfiles/.zshrc $HOME/.config/dotfiles/.profile $HOME/'

# https://asdf-vm.com/guide/getting-started.html
context 'Installing asdf, nodejs, python'
run 'git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0'
run 'source ~/.zshrc'
# https://github.com/danhper/asdf-python
run 'asdf plugin-add python'
run 'asdf install python latest'
run 'asdf global python latest'
# https://github.com/asdf-vm/asdf-nodejs
run 'asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git'
run 'asdf install nodejs latest'
run 'asdf global nodejs latest'

context 'Installing shell customizations: oh-my-zsh and powerlevel10k'
# https://github.com/ohmyzsh/ohmyzsh#advanced-installation
run 'git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.config/.oh-my-zsh'
# https://github.com/romkatv/powerlevel10k#oh-my-zsh
run 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.config/.oh-my-zsh/custom}/themes/powerlevel10k'

context 'Installing vim customizations: vim-plug'
run "sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'"

run 'mkdir -p $HOME/ws/3p'

context 'Installing font: UbuntuMono Nerd Font'
# https://github.com/ryanoasis/nerd-fonts#option-6-ad-hoc-curl-download
run 'git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git $HOME/ws/3p/nerd-fonts'
# https://github.com/ryanoasis/nerd-fonts#option-3-install-script
run 'pushd $HOME/ws/3p/nerd-fonts'
run 'git sparse-checkout add patched-fonts/UbuntuMono'
run './install.sh UbuntuMono'
run 'popd'
