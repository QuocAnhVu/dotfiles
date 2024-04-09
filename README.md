# Run install script via curl

```sh
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl zsh
zsh -c "$(curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/install.sh)"
cd ~/.local/share/dotfiles
./install_langs.sh
./harden_ssh.sh
```
