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
  git/                  git config and global ignore (delta as pager, aliases)
  helix/                main editor
  mise/                 global tool versions (Python, Node, Go, Lua)
  nvim/                 occasional editor (plugins come from home/full.nix)
  nushell/              interactive shell
  zsh/                  login shell: .zshenv (environment), .zshrc (interactive)
  zellij/               terminal multiplexer
  starship.toml         prompt
.bashrc                 bash (rarely used)
bin/                    personal scripts, on PATH
setup.sh                sets up a machine for its role: packages, Nix and home-manager,
                        toolchains, theme, GNOME extensions, SSH
theme.sh                switches the terminal, editor and GNOME theme
_lib.sh                 helpers for the scripts above
.ssh/                   my public keys (authorized_keys)
```

## Machine roles

| Role               | OS            | `setup.sh` / home-manager    | SSH server | Notes                          |
| ------------------ | ------------- | ---------------------------- | ---------- | ------------------------------ |
| This workstation   | Fedora/Debian | `workstation`                | off        | GNOME, desktop apps, NVIDIA    |
| Remote desktop     | Debian        | `desktop`                    | on         | GNOME, Firefox, terminal; RDP through an SSH tunnel |
| Headless dev box   | Debian        | `dev`                        | on         | full toolset, no GUI           |
| Headless server    | Debian        | `server` (optional)          | on         | a few debugging tools; no checkout needed |

Each role includes the one before it:

| Role          | home-manager adds                                                      | system packages (`setup.sh`) add                     |
| ------------- | ---------------------------------------------------------------------- | ---------------------------------------------------- |
| `server`      | zsh/bash and helix configs, starship, git, ripgrep, fd, bat, mosh…      | nothing                                              |
| `dev`         | CLI/TUI suite, mise, rustup, uv, language servers, cargo tools, direnv  | compilers, cmake, meson, clangd, podman              |
| `desktop`     | Alacritty config, JetBrainsMono Nerd Font, distrobox                   | GNOME (if missing), RDP server, Firefox, Alacritty   |
| `workstation` | Flatpak apps (`home/workstation.nix`), GNOME extension settings (`home/gnome.nix`) | KeePassXC, virt-manager, nvtop, Performous, Mullvad, NVIDIA driver and container toolkit |

Where everything else comes from:

| What                                   | From                                   | Why not Nix                                  |
| -------------------------------------- | -------------------------------------- | -------------------------------------------- |
| Desktop apps (Steam, Discord, Blender…) | Flatpak, listed in `home/workstation.nix` | Nix-built GUI apps can't use the system GPU drivers on non-NixOS |
| Firefox, KeePassXC, Alacritty, Mullvad, virt-manager, nvtop | `setup.sh` (apt/dnf, vendor repos; Alacritty via cargo on Debian) | need system integration (browser↔KeePassXC, VPN service, libvirt) |
| Compilers, `cmake`, `meson`, `clangd`, `-dev` libraries | `setup.sh` / apt, dnf                | Nix's builds don't search `/usr`             |
| NVIDIA driver, container toolkit       | `setup.sh` (RPM Fusion / NVIDIA's Debian repo)          | kernel module                     |
| GNOME extensions                       | extensions.gnome.org (`setup.sh`), enabled and configured in `home/gnome.nix` | match the running GNOME Shell version |
| CUDA toolkit                           | the `cuda` distrobox (see below)       | needs an older GCC than Fedora's             |
| VeraCrypt                              | manual download (veracrypt.io)         | not packaged                                 |

## Setting up a machine

### 0. Installing Debian

Use the Debian 13 (trixie) amd64 **netinst** image (debian.org → "Download";
the small image that fetches packages during the install). In the installer:

- **Leave the root password empty.** Your user then gets `sudo`, which
  `setup.sh` needs (it stops and says so otherwise). With a root password:
  `su -c 'usermod -aG sudo <user>'`, then log in again.
- **Software selection**: workstation and remote desktops: *GNOME* and
  *standard system utilities* (GNOME brings NetworkManager, for Wi-Fi). Headless
  machines: *SSH server* and *standard system utilities*, so you can log in to
  run `setup.sh`, which then hardens sshd.
- With Secure Boot and an NVIDIA card: after `setup.sh` installs the driver,
  enroll the module signing key (`sudo mokutil --import /var/lib/dkms/mok.pub`)
  and confirm it in the blue MOK screen on the next boot.

`setup.sh` adds Mozilla's, Mullvad's and NVIDIA's repositories itself. The NVIDIA
driver comes from NVIDIA's repository (the current one, open kernel modules),
not Debian's, which is too old for smooth gaming under Wayland.

### 1. Prerequisites and checkout

```shell
sudo apt install -y zsh git   # Debian
sudo dnf install -y zsh git   # Fedora

git clone https://github.com/QuocAnhVu/dotfiles.git ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
chsh -s "$(command -v zsh)"
```

The checkout must be at `~/.local/share/dotfiles`; config files link there. If
you keep it elsewhere (I use `~/ws/dotfiles`), symlink it to that path.

### 2. Run setup.sh

```shell
./setup.sh workstation   # or: desktop, dev, server
```

It runs the role's steps in order, and is safe to rerun. To run some steps
only, name them: `./setup.sh dev home langs`. `./setup.sh` lists them:

| Step         | Does                                                                 | Roles        |
| ------------ | -------------------------------------------------------------------- | ------------ |
| `base`       | XDG directories, curl/git/ripgrep, automatic updates, firewalld (incoming: only allowed services) | all |
| `packages`   | system packages (see the tables above), podman                       | all but server |
| `home`       | installs Nix (asks for sudo), applies the home-manager profile       | all          |
| `langs`      | mise tools (`.config/mise/config.toml`), pnpm, Rust stable; Alacritty on Debian | all but server |
| `theme`      | reapplies the theme the configs select (`./theme.sh --current`)      | workstation, desktop |
| `extensions` | installs the GNOME extensions `home/gnome.nix` enables               | workstation  |
| `ssh`        | client key; a hardened sshd with the keys in `.ssh/authorized_keys`  | all (no sshd on the workstation) |

Afterwards, open a new shell; on desktops, log out and back in so GNOME picks
up the environment and loads new extensions.

The `home` step installs Nix with the Determinate Systems installer when systemd is
running (it supports SELinux, unlike the official installer) and as a
single-user install otherwise (containers). It moves aside existing files that
are in the way with a `.pre-hm` suffix.

### 3. Machine-specific files

Two files aren't in git (`setup.sh` creates empty ones):

- `~/.config/environment.d/90-local.conf`: variables for this machine only,
  such as SDK paths. systemd `environment.d` format, `${VAR}` expansion works:
  ```
  PATH=/usr/local/cuda/bin:${PATH}
  VULKAN_SDK=${HOME}/.local/share/vulkan/1.3.283.0/x86_64
  ```
- `~/.config/secrets.env`: API keys, `KEY=VALUE` per line, literal values.
  Keep it `chmod 600`.

### Data drive (workstation)

Bulky data lives on a separate drive mounted at `/mnt/data`; the system drive
keeps programs, games and `~/ws`. `home/workstation.nix` points Documents,
Pictures, Videos and Music there (Desktop and Downloads stay local; Public and
Templates are off), and a timer backs up `~/ws` to it. Each machine's
`/etc/fstab` decides which drive that is. With systemd's automount, a missing
drive makes writes fail instead of landing on the system drive:

```
/dev/mapper/<name> /mnt/data btrfs noatime,compress=zstd:1,nofail,x-systemd.automount,x-systemd.device-timeout=10s 0 0
```

(plus its `/etc/crypttab` line if it's encrypted). Layout: `Documents/`, `Pictures/`,
`Videos/`, `Music/`, `Models/`, `Datasets/`, `ws/` (backup), `ws-history/`.

**ws backup**: `bin/ws-backup` runs hourly (`systemctl --user list-timers
ws-backup`) and skips quietly while the drive is disconnected. It leaves out
build output, caches and 3p clones (it keeps `3p save`'s list), at most 50 MiB/s
since the drive overheats. Files deleted or changed since the previous run stay
in `/mnt/data/ws-history/<date_time>/` for 30 days. To leave out more, add
rsync filter rules to a `.backupignore` file in that directory (`- /big-data/`).
Restore with `rsync -a /mnt/data/ws/ ~/ws/`, then `3p restore --all` for the
clones you want. Check the last run with `journalctl --user -u ws-backup`.

### Role-specific steps

- **Headless server without a checkout**: skip the clone and apply the profile
  straight from GitHub (needs Nix with flakes; uses what's pushed):
  ```shell
  nix run github:QuocAnhVu/dotfiles#home-manager -- switch --flake github:QuocAnhVu/dotfiles#quocanh@server
  ```
- **Remote desktop**: `setup.sh desktop` installs the RDP server and an SSH server; turn on RDP in GNOME Settings →
  System → Remote Desktop (or with `grdctl`), but keep port 3389 closed and
  connect through SSH: `ssh -L 3389:localhost:3389 <host>`, then point the RDP
  client at `localhost`.
- **Optional extras**: Tailscale (`curl -fsSL https://tailscale.com/install.sh | sh`).
  (Caps Lock as Esc is set on the workstation by `home/gnome.nix`; elsewhere:
  `gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape_shifted_capslock']"`.)

## Everyday use

**Terminal**: Alacritty starts zellij, which opens nushell. zsh is the login
shell (TTYs, SSH, scripts that expect a POSIX shell). Environment variables come
from the desktop session, so every shell sees the same ones.

**Applying changes**: config files under `.config/` are linked into the
checkout, so most edits apply right away. The rest:

| You changed                              | To apply                                                        |
| ---------------------------------------- | --------------------------------------------------------------- |
| A file under `.config/`                  | nothing (restart the program, or reload: `:config-reload` in helix) |
| `home/*.nix` or `flake.lock`             | `home-manager switch --flake ~/.local/share/dotfiles#quocanh@<role>` |
| Shared variables in `home/*.nix`         | the switch above, then log out and back in                      |
| `~/.config/environment.d/90-local.conf`  | log out and back in (new zsh/bash shells pick it up right away) |
| `~/.config/secrets.env`                  | open a new shell                                                |

**Themes**: `./theme.sh everforest` (or `gruvbox`, `nord`) switches Alacritty,
helix, zellij, Neovim, delta (git diffs), the GTK theme and the GNOME Shell theme. It installs a GTK theme
the first time; `./theme.sh -u <theme>` updates it.

**Language versions**: mise manages Python, Node, Go and Lua. Global versions
are in `.config/mise/config.toml` (`mise use -g node@lts` edits it in the repo;
commit the change), per-project ones in a `mise.toml`. rustup manages Rust.

**Per-project Nix dev shells (direnv)**: put `use flake` in a project's
`.envrc` next to its `flake.nix`, run `direnv allow` once, and its dev shell
loads whenever you `cd` in (zsh, bash and nushell; nix-direnv caches it).

**Git**: `git lg` (graph log), `git wt <feature>` (new worktree on
`feature/<feature>` next to the repo), `git difft` (difftastic); diffs page
through delta, whose colours follow `theme.sh`.

**Containers for other distros (distrobox)**: shares your home folder, user and
display. Useful for software that wants an older or different distro, such as
CUDA (which needs an older GCC than Fedora's):

```shell
distrobox create --name cuda --image docker.io/nvidia/cuda:12.9.1-devel-ubuntu24.04 --nvidia
distrobox enter cuda               # same home folder and Nix tools; `exit` to leave
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

**GNOME extensions**: add the UUID (shown on the extension's
extensions.gnome.org page or by `gnome-extensions list`) to `enabled-extensions`
in `home/gnome.nix`, switch, then `./setup.sh workstation extensions` installs
it. To keep a setting, change it in the extension's preferences, find the key
with `dconf watch /org/gnome/shell/extensions/` (or `dconf dump`), and add it
to `home/gnome.nix`; otherwise the next switch leaves it alone, but a new
machine won't have it.

## Updating

| What                     | How                                                                 |
| ------------------------ | ------------------------------------------------------------------- |
| These dotfiles           | `git pull`, then `home-manager switch --flake ~/.local/share/dotfiles#quocanh@<profile>` |
| Nix packages             | `nix flake update`, switch, check things work, commit `flake.lock` (roll back if not) |
| GTK themes               | `./theme.sh -u <theme>`                                             |
| System packages          | automatic (`setup.sh` enables dnf-automatic / unattended-upgrades)  |
| Flatpak apps, GNOME extensions | automatic (nix-flatpak weekly; GNOME Shell for extensions)    |
| Nix itself               | `sudo -i nix upgrade-nix`; check first that it stays upstream Nix (the installer's `/etc/nix/nix.conf` points upgrades at a Determinate Systems URL) |
| Toolchains               | `mise upgrade` (commit `.config/mise/config.toml` if versions change), `rustup update` |

Old home-manager generations older than 30 days are deleted weekly
(`nix.gc` in `home/common.nix`); `nix-collect-garbage -d` frees space now.

## Troubleshooting

- **A new terminal lacks a tool or variable**: variables come from the desktop
  session, which is set at login; log out and back in. Long-running programs
  (an old zellij session) keep the environment they started with: close them.
- **`setup.sh` or `home-manager switch` says a file is in the way**: `setup.sh`
  renames such files to `*.pre-hm`; with plain `home-manager switch`, add
  `-b pre-hm`. Compare and delete the backup.
- **Check the editor setup**: `hx --health <language>` shows which language
  servers helix finds.
- **The Nix installer refuses to run on Fedora (SELinux)**: use `setup.sh`, which
  uses the installer that supports SELinux. Uninstall with
  `sudo /nix/nix-installer uninstall`, never by deleting `/nix`.
- **Nix warns "ignoring the client-specified setting 'use-xdg-base-directories'"**:
  the setting is in `~/.config/nix/nix.conf` instead of the system config; run
  `./setup.sh <role> home`, which puts it in `/etc/nix`.
