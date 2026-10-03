# Automatically install everything

```shell
sudo dnf update -y
sudo dnf install -y zsh git ripgrep

XDG_DATA_HOME=$HOME/.local/share
mkdir -p $XDG_DATA_HOME/dotfiles
git clone https://github.com/QuocAnhVu/dotfiles.git $XDG_DATA_HOME/dotfiles

cd $XDG_DATA_HOME/dotfiles
./base.sh
./home.sh desktop      # or dev, server (see below); then open a new shell
./langs.sh
./harden.sh            # SSH key; asks before enabling sshd (only for remote hosts)
./theme.sh everforest  # or gruvbox, nord
```

## Nix and home-manager

`home.sh <profile>` installs Nix if needed and applies a home-manager profile
from `flake.nix`. Each profile includes the one before it:

| Profile   | For                     | Adds                                                         |
| --------- | ----------------------- | ------------------------------------------------------------ |
| `server`  | Headless servers        | Shell and helix configs, a few CLI tools for debugging       |
| `dev`     | Headless dev machines   | Full CLI/TUI suite, mise + rustup, language servers          |
| `desktop` | Local/remote desktops   | Alacritty config, JetBrainsMono Nerd Font                     |

`desktop` and `dev` link config directories to this checkout, so edits (and
`theme.sh`) apply immediately. `server` copies them into the Nix store, so it
works without a checkout:

```shell
nix run github:QuocAnhVu/dotfiles#home-manager -- switch --flake github:QuocAnhVu/dotfiles#quocanh@server
```

After changing `home/*.nix`: `home-manager switch --flake ~/.local/share/dotfiles#quocanh@<profile>`.
Update pinned packages with `nix flake update`.

Environment variables (XDG locations, `EDITOR`, `PATH`) are set in `home/*.nix`
and reach both shells and the desktop session (`~/.config/environment.d`; log
out and back in after changing them). zsh reads `~/.config/zsh/.zshrc`. Scripts
in `bin/` are on `PATH` for `desktop` and `dev`. Machine-specific settings and
secrets go in the untracked `~/.config/localrc`.

GUI apps (alacritty, browsers, keepassxc), compilers, cmake/meson, clangd and
`-dev` libraries come from the system package manager or Flatpak, not Nix.

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

## Install GUI apps

```shell
sudo dnf install alacritty xxd   # or apt
```

## Swap caps:escape

Follow instructions for your desktop environment.
