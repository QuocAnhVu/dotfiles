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

## Switch from grub2 to systemd-boot

```shell
# Remove grub2, install systemd-boot
sudo mkdir /boot/efi/$(cat /etc/machine-id)
sudo rm /etc/dnf/protected.d/grub* /etc/dnf/protected.d/shim*
sudo dnf remove -y grubby grub2\* && sudo rm -rf /boot/grub2 && sudo rm -rf /boot/loader
sudo dnf install -y systemd-boot-unsigned sdubby

# Reconfigure kernel
cat /proc/cmdline | cut -d ' ' -f 2- | sudo tee /etc/kernel/cmdline
sudo bootctl install
sudo kernel-install add $(uname -r) /lib/modules/$(uname -r)/vmlinuz
sudo dnf reinstall kernel-core

# Test config
sudo bootctl
```
