# Automatically install everything

```shell
sudo dnf update -y
sudo dnf install -y zsh curl ripgrep
curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/install.sh | zsh
cd ~/.local/share/dotfiles
./install_langs.sh
./harden_ssh.sh
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
