# Automatically install everything

```shell
sudo dnf update -y
sudo dnf install -y zsh git ripgrep

XDG_DATA_HOME=$HOME/.local/share
mkdir -p $XDG_DATA_HOME/dotfiles
git clone https://github.com/QuocAnhVu/dotfiles.git $XDG_DATA_HOME/dotfiles

cd $XDG_DATA_HOME/dotfiles
./base.sh
./langs.sh
./harden.sh
```

# Manual post-install tasks

## Set default shell to zsh

```shell
chsh -s $(which zsh)
```

## Install Treesitter parsers

```shell
nvim \
    -c 'TSInstall all' \
    -c 'qa!'
```

## Install Tailscale

```shell
curl -fsSL https://tailscale.com/install.sh | sh
```

## Install apps

```shell
sudo dnf install alacritty fzf xxd
cargo install nu starship zellij
go install github.com/boyter/scc@master
go install github.com/charmbracelet/glow@latest
npm install -g tldr
```

## Swap caps:escape

Follow instructions for your desktop environment.

## Install fonts

```shell
git clone --filter=blob:none git@github.com:ryanoasis/nerd-fonts
cd nerd-fonts
```

### Install one font:

```shell
git sparse-checkout add patched-fonts/JetBrainsMono
```

### Install all fonts:

```shell
./install.sh
```
