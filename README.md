# Dotfiles

Configuration for my machines: shell, editor, terminal and desktop theme, plus
the tools I use. The base system is Debian or Fedora, managed with its own
package manager and a few setup scripts. My user environment (CLI tools,
language servers, config files, environment variables) comes from
[home-manager](https://github.com/nix-community/home-manager) on Nix, so it's
the same everywhere.

- [Layout](#layout)
- [Machine roles](#machine-roles)
- [Setting up a machine](#setting-up-a-machine)
- [Everyday use](#everyday-use)
- [Customizing](#customizing)
- [Updating](#updating)
- [Troubleshooting](#troubleshooting)

## Layout

```
flake.nix, flake.lock   home-manager profiles and pinned package versions
home/                   the profiles: minimal.nix -> full.nix -> desktop.nix (see home/README.md)
.config/                config files, linked into ~/.config by home-manager
  alacritty/            terminal (themes/ holds the colour schemes)
  helix/                main editor
  nvim/                 occasional editor (plugins come from home/full.nix)
  nushell/              interactive shell
  zsh/                  login shell: .zshenv (environment), .zshrc (interactive)
  zellij/               terminal multiplexer
  starship.toml         prompt
.bashrc                 bash (rarely used)
bin/                    personal scripts, on PATH
base.sh                 system setup: XDG directories, base packages, automatic updates
home.sh                 installs Nix and applies a home-manager profile
langs.sh                language toolchains through mise (Python, Node, Go) and rustup
harden.sh               SSH: client key, and optionally a hardened sshd
theme.sh                switches the terminal, editor and GNOME theme
_lib.sh                 helpers for the scripts above
.ssh/                   my public keys (authorized_keys)
```

## Machine roles

| Role               | OS            | home-manager profile | SSH server | Notes                                  |
| ------------------ | ------------- | -------------------- | ---------- | -------------------------------------- |
| This desktop       | Fedora/Debian | `desktop`            | off        | GNOME                                  |
| Remote desktop     | Debian        | `desktop`            | on         | GNOME, RDP through an SSH tunnel       |
| Headless dev box   | Debian        | `dev`                | on         | full toolset, no GUI                   |
| Headless server    | Debian        | `server` (optional)  | on         | a few debugging tools; no checkout needed |

Each profile includes the one before it:

| Profile   | Adds                                                                                 |
| --------- | ------------------------------------------------------------------------------------ |
| `server`  | zsh/bash and helix configs, starship, git, ripgrep, fd, bat, bottom, mosh…           |
| `dev`     | CLI/TUI suite (zellij, nushell, eza…), mise, rustup, uv, language servers, cargo tools |
| `desktop` | Alacritty config, JetBrainsMono Nerd Font, distrobox                                 |

What deliberately does **not** come from Nix: GUI apps (Alacritty, browsers,
KeePassXC: Nix-built GUI apps can't use the system's GPU drivers on non-NixOS),
compilers and `-dev` libraries, `cmake`/`meson`/`clangd` (Nix's versions don't
search `/usr`, so they can't find apt/dnf libraries), CUDA and drivers. Install
those with apt/dnf or Flatpak.

## Setting up a machine

### 1. Prerequisites and checkout

```shell
sudo apt install -y zsh git ripgrep curl   # Debian
sudo dnf install -y zsh git ripgrep curl   # Fedora

git clone https://github.com/QuocAnhVu/dotfiles.git ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
chsh -s "$(command -v zsh)"
```

The checkout must be at `~/.local/share/dotfiles`; config files link there. If
you keep it elsewhere (I use `~/ws/dotfiles`), symlink it to that path.

### 2. Run the setup scripts

```shell
./base.sh            # XDG directories, base packages, automatic updates
./home.sh desktop    # or: dev, server. Installs Nix (asks for sudo) and applies the profile
```

Open a new shell, then:

```shell
./langs.sh                # Python, Node, Go (mise) and the Rust stable toolchain
./harden.sh               # SSH key; asks whether this machine should accept SSH
./theme.sh everforest     # desktops only: or gruvbox, nord
```

On desktops, log out and back in so GNOME picks up the environment.

`home.sh` installs Nix with the Determinate Systems installer when systemd is
running (it supports SELinux, unlike the official installer) and as a
single-user install otherwise (containers). It moves aside existing files that
are in the way with a `.pre-hm` suffix.

### 3. Machine-specific files

Two files aren't in git (`base.sh` creates empty ones):

- `~/.config/environment.d/90-local.conf`: variables for this machine only,
  such as SDK paths. systemd `environment.d` format, `${VAR}` expansion works:
  ```
  PATH=/usr/local/cuda/bin:${PATH}
  VULKAN_SDK=${HOME}/.local/share/vulkan/1.3.283.0/x86_64
  ```
- `~/.config/secrets.env`: API keys, `KEY=VALUE` per line, literal values.
  Keep it `chmod 600`.

### Role-specific steps

- **Headless server without a checkout**: skip the clone and apply the profile
  straight from GitHub (needs Nix with flakes; uses what's pushed):
  ```shell
  nix run github:QuocAnhVu/dotfiles#home-manager -- switch --flake github:QuocAnhVu/dotfiles#quocanh@server
  ```
- **Remote desktop**: answer yes in `harden.sh`. Turn on RDP in GNOME Settings →
  System → Remote Desktop (or with `grdctl`), but keep port 3389 closed and
  connect through SSH: `ssh -L 3389:localhost:3389 <host>`, then point the RDP
  client at `localhost`.
- **Optional extras**: Tailscale (`curl -fsSL https://tailscale.com/install.sh | sh`),
  Caps Lock as Escape (`gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"`).

## Everyday use

**Terminal**: Alacritty starts zellij, which opens nushell. zsh is the login
shell (TTYs, SSH, scripts that expect a POSIX shell). Environment variables come
from the desktop session, so every shell sees the same ones.

**Applying changes**: config files under `.config/` are linked into the
checkout, so most edits apply right away. The rest:

| You changed                              | To apply                                                        |
| ---------------------------------------- | --------------------------------------------------------------- |
| A file under `.config/`                  | nothing (restart the program, or reload: `:config-reload` in helix) |
| `home/*.nix` or `flake.lock`             | `home-manager switch --flake ~/.local/share/dotfiles#quocanh@desktop` |
| Shared variables in `home/*.nix`         | the switch above, then log out and back in                      |
| `~/.config/environment.d/90-local.conf`  | log out and back in (new zsh/bash shells pick it up right away) |
| `~/.config/secrets.env`                  | open a new shell                                                |

**Themes**: `./theme.sh everforest` (or `gruvbox`, `nord`) switches Alacritty,
helix, zellij, Neovim, the GTK theme and the GNOME Shell theme. It installs a GTK theme
the first time; `./theme.sh -u <theme>` updates it.

**Language versions**: mise manages Python, Node, Go and Lua (`mise use -g node@lts`,
or a `mise.toml` per project); rustup manages Rust (`rustup default stable`).

**Containers for other distros (distrobox)**: shares your home folder, user and
display. Useful for software that wants an older or different distro, such as
CUDA (which needs an older GCC than Fedora's):

```shell
distrobox create --name cuda --image docker.io/nvidia/cuda:12.9.1-devel-ubuntu24.04 \
  --nvidia --volume /nix:/nix:ro   # /nix makes the Nix tools work inside
distrobox enter cuda               # same home folder; `exit` to leave
distrobox list | stop | rm cuda
```

**Rolling back home-manager**: `home-manager generations` lists previous
versions; run `<path from the list>/activate` to switch back to one.

## Customizing

**Add a CLI tool**: find its name with `nix search nixpkgs <name>`, add it to
`home.packages` in the right profile (`minimal.nix` for servers, `full.nix` for
dev machines, `desktop.nix` for desktops), then switch. See `home/README.md`.

**Neovim**: plugins and Treesitter grammars are listed in `programs.neovim.plugins`
in `home/full.nix` (no plugin manager; versions pinned by `flake.lock`), and
configured in `.config/nvim/init.lua`. Language servers are the ones helix uses.

**Add a config file**: put it under `.config/` and add a line such as
`xdg.configFile."foo".source = link ".config/foo";` to the profile.

**Environment variables**:

| What                                  | Where                                    | Seen by                        |
| ------------------------------------- | ---------------------------------------- | ------------------------------ |
| Shared (XDG locations, `EDITOR`, PATH) | `home.sessionVariables` / `home.sessionPath` in `home/*.nix` | desktop session, zsh, bash |
| This machine only                     | `~/.config/environment.d/90-local.conf`  | desktop session, zsh, bash     |
| Secrets                               | `~/.config/secrets.env`                  | interactive zsh, bash, nushell |

Nushell inherits the session's variables, so it needs no copies. Keep secrets
out of `environment.d`: everything in it is visible to every app in the session.

**Shell settings**: aliases and prompt setup are per shell:
`.config/zsh/.zshrc`, `.config/nushell/config.nu`, `.bashrc`. The nushell and
zellij configs only list what differs from the defaults (`config nu --doc`,
`zellij setup --dump-config`).

**Scripts**: put them in `bin/` and make them executable (`chmod +x`).

**Themes**: `theme.sh` has a table of theme names per program at the top. To add
one, add a column there and the option lines in `alacritty.toml` (plus a file in
`alacritty/themes/`), `helix/config.toml` and `zellij/config.kdl`.

**GUI apps**: apt/dnf or Flatpak, not Nix.

## Updating

| What                     | How                                                                 |
| ------------------------ | ------------------------------------------------------------------- |
| These dotfiles           | `git pull`, then `home-manager switch --flake ~/.local/share/dotfiles#quocanh@<profile>` |
| Nix packages             | `nix flake update`, switch, check things work, commit `flake.lock` (roll back if not) |
| GTK themes               | `./theme.sh -u <theme>`                                             |
| System packages          | automatic (`base.sh` enables dnf-automatic / unattended-upgrades)   |
| Nix itself               | `sudo -i nix upgrade-nix`; check first that it stays upstream Nix (the installer's `/etc/nix/nix.conf` points upgrades at a Determinate Systems URL) |
| Toolchains               | `mise upgrade`, `rustup update`                                     |

Old home-manager generations older than 30 days are deleted weekly
(`nix.gc` in `home/common.nix`); `nix-collect-garbage -d` frees space now.

## Troubleshooting

- **A new terminal lacks a tool or variable**: variables come from the desktop
  session, which is set at login; log out and back in. Long-running programs
  (an old zellij session) keep the environment they started with: close them.
- **`home.sh` or `home-manager switch` says a file is in the way**: `home.sh`
  renames such files to `*.pre-hm`; with plain `home-manager switch`, add
  `-b pre-hm`. Compare and delete the backup.
- **Check the editor setup**: `hx --health <language>` shows which language
  servers helix finds.
- **The Nix installer refuses to run on Fedora (SELinux)**: use `home.sh`, which
  uses the installer that supports SELinux. Uninstall with
  `sudo /nix/nix-installer uninstall`, never by deleting `/nix`.
- **Nix warns "ignoring the client-specified setting 'use-xdg-base-directories'"**:
  the setting is in `~/.config/nix/nix.conf` instead of the system config; rerun
  `home.sh`, which moves it to `/etc/nix`.
