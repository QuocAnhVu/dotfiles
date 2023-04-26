# Run install script via curl

```sh
bash -ci "$(curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/preinstall.sh)"
zsh -c "$(curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/install.sh)"
zsh -c "$(curl -fsSL https://raw.github.com/QuocAnhVu/dotfiles/master/harden_ssh.sh)"
```

# SSH Hardening

After running install script, see [harden_ssh.sh](harden_ssh.sh) for commands to harden ssh and sshd.
