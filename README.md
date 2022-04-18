# Install packages

```sh
sudo dnf install curl git                # dotfiles dependency

sudo dnf install zsh neovim ripgrep      # Shell + text editor

# python build dependencies (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
sudo dnf install make gcc zlib-devel bzip2 bzip2-devel \
    readline-devel sqlite sqlite-devel \
    openssl-devel tk-devel libffi-devel xz-devel

sudo dnf install gcc-c++                 # nodejs build dependencies (https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms)

sudo dnf install i3 polybar sway waybar  # window managers: i3/sway + polybar/waybar
```

# Remove old config files

```sh
rm -rf ~/.zshrc ~/.tmux.conf ~/.profile ~/.p10k.zsh ~/.config/alacritty ~/.config/i3 ~/.config/nvim ~/.config/polybar ~/.config/powerlevel10k ~/.config/sway ~/.config/waybar
```

# Run install script via curl

```sh
sh -c "$(curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/install.sh)"
```
