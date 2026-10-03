#! /usr/bin/zsh
# Set up a machine for a role: system packages, Nix and home-manager, language
# toolchains, theme, GNOME extensions and SSH. Debian or Fedora. Safe to rerun.
#
# Usage: ./setup.sh <role> [step...]
#   Roles:
#     workstation  this desktop: GNOME, desktop apps, NVIDIA. No SSH server.
#     desktop      remote desktops: GNOME with RDP, Firefox, Alacritty; SSH
#     dev          headless, all the tools; SSH
#     server       headless, minimal tools; SSH
#   Steps (default: all of the role's, in this order):
#     base        XDG directories, curl/git, automatic updates, firewall
#     packages    system packages (apt/dnf and vendor repos)
#     home        Nix and the home-manager profile quocanh@<role>
#     langs       mise tools, pnpm, Rust (and Alacritty on Debian, through cargo)
#     theme       reapply the theme selected in the configs (./theme.sh)
#     extensions  install the GNOME extensions enabled in home/gnome.nix
#     ssh         client key; a hardened sshd (not on the workstation)
source $(dirname $0)/_lib.sh
setopt err_exit

SCRIPT=$0
DOTFILES=$(cd $(dirname $0) && pwd)
ALL_STEPS=(base packages home langs theme extensions ssh)
typeset -A ROLE_STEPS
ROLE_STEPS=(
    workstation "base packages home langs theme extensions ssh"
    desktop     "base packages home langs theme ssh"
    dev         "base packages home langs ssh"
    server      "base home ssh"
)

function usage() {
    sed -n '/^# Usage/,/^[^#]/p' $SCRIPT | sed '$d; s/^# \{0,1\}//'
    exit 1
}

role=$1
[[ -n $role && -n ${ROLE_STEPS[$role]} ]] || usage
shift
steps=(${=ROLE_STEPS[$role]})
if (( $# )); then
    for s in $@; do (( ${ALL_STEPS[(Ie)$s]} )) || usage; done
    steps=($@)
fi

if grep -q '^ID=fedora' /etc/os-release; then
    distro=fedora
elif grep -q '^ID=debian' /etc/os-release; then
    distro=debian
else
    message 'Only Debian and Fedora are supported.'; exit 1
fi

function install() {
    if [[ $distro == fedora ]]; then
        run sudo dnf install -y $@
    else
        run sudo apt-get install -y $@
    fi
}

# Puts the home-manager profile's tools and variables (PATH, CARGO_HOME,
# RUSTUP_HOME...) into this shell, for the steps after `home`
function load_home_env() {
    local profile=$XDG_STATE_HOME/nix/profile
    [[ -d $profile/bin ]] || profile=$HOME/.nix-profile
    for f in /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh(N) $profile/etc/profile.d/hm-session-vars.sh(N); do
        unset __HM_SESS_VARS_SOURCED
        source $f
    done
    path=($profile/bin $path)
}

# --- base -------------------------------------------------------------------

function step_base() {
    context 'XDG and prerequisite directories'
    run mkdir -p $XDG_CONFIG_HOME $XDG_CACHE_HOME $XDG_DATA_HOME $XDG_STATE_HOME
    run mkdir -p $HOME/ws
    run mkdir -p $XDG_STATE_HOME/bash $XDG_STATE_HOME/zsh # shell history
    run mkdir -p $XDG_CONFIG_HOME/environment.d           # machine-specific variables: 90-local.conf
    run "touch $XDG_CONFIG_HOME/secrets.env && chmod 600 $XDG_CONFIG_HOME/secrets.env"

    context 'Base packages (the rest comes from the next steps)'
    if [[ $distro == fedora ]]; then
        run sudo dnf upgrade -y
    else
        run sudo apt-get update
        run sudo apt-get upgrade -y
    fi
    install curl git ripgrep pciutils

    context 'Automatic updates'
    if [[ $distro == fedora ]]; then
        # dnf5: defaults are in /usr/share/dnf5/dnf5-plugins/automatic.conf; override here
        install dnf-automatic
        run_noeval "apply_updates = yes > /etc/dnf/dnf5-plugins/automatic.conf"
        printf '[commands]\napply_updates = yes\n' | sudo tee /etc/dnf/dnf5-plugins/automatic.conf > /dev/null
        run sudo systemctl enable --now dnf5-automatic.timer
    else
        install unattended-upgrades
        run_noeval "enable unattended-upgrades (debconf)"
        echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | sudo debconf-set-selections
        run sudo dpkg-reconfigure -f noninteractive unattended-upgrades
    fi

    # firewalld: Fedora's default, and on Debian (which has no firewall) so both
    # work the same. podman and libvirt integrate with it. Default zone: incoming
    # connections only for the services it lists (ssh: decided in the ssh step).
    context 'Firewall'
    (( $+commands[firewall-cmd] )) || install firewalld
    run sudo systemctl enable --now firewalld
    message "Zone $(sudo firewall-cmd --get-default-zone), allowing: $(sudo firewall-cmd --list-services)"
}

# --- packages ---------------------------------------------------------------
# What doesn't come from Nix (home-manager) or Flatpak (nix-flatpak):
#   dev:         build tools, podman
#   desktop:     + GNOME (if missing) with RDP, Firefox, Alacritty
#   workstation: + KeePassXC, virt-manager, nvtop, Steam udev rules, Mullvad, NVIDIA

# Adds an apt repository: name, key URL, "deb ..." line ({key} is replaced by the key path)
function apt_repo() {
    local name=$1 key_url=$2 line=$3 key=/etc/apt/keyrings/$1.asc
    if [[ ! -f /etc/apt/sources.list.d/$name.list ]]; then
        run sudo install -d -m 0755 /etc/apt/keyrings
        run sudo curl -fsSLo $key $key_url
        run_noeval "${line//\{key\}/$key} > /etc/apt/sources.list.d/$name.list"
        print -r -- ${line//\{key\}/$key} | sudo tee /etc/apt/sources.list.d/$name.list > /dev/null
        run sudo apt-get update
    fi
}

# RPM Fusion: the NVIDIA driver
function rpmfusion() {
    local v=$(rpm -E %fedora)
    rpm --quiet -q rpmfusion-nonfree-release || run sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$v.noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$v.noarch.rpm
}

# NVIDIA's Debian repository: the current driver and the container toolkit.
# Debian's own driver lags far behind (no Wayland explicit sync before 555,
# which XWayland games under Proton need to run smoothly).
function nvidia_repo() {
    dpkg -s cuda-keyring > /dev/null 2>&1 && return 0
    local deb=$(mktemp --suffix=.deb) v=$(. /etc/os-release && print $VERSION_ID)
    run curl -fsSLo $deb https://developer.download.nvidia.com/compute/cuda/repos/debian$v/x86_64/cuda-keyring_1.1-1_all.deb
    run sudo dpkg -i $deb
    rm -f $deb
    run sudo apt-get update
}

function step_packages() {
    context 'Build tools (Nix versions of cmake/meson/clangd do not see system libraries)'
    if [[ $distro == fedora ]]; then
        install gcc gcc-c++ make cmake meson pkgconf-pkg-config clang-tools-extra
    else
        install build-essential cmake meson pkg-config clangd
    fi

    context 'Podman (rootless containers; distrobox uses it)'
    install podman
    # Rootless containers need subordinate user/group IDs: users created
    # before uidmap/shadow tooling was installed may have none
    if ! grep -q "^$USER:" /etc/subuid 2> /dev/null; then
        run sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
    fi
    [[ $role == dev ]] && return

    context 'GNOME'
    if ! (( $+commands[gnome-shell] )); then
        if [[ $distro == fedora ]]; then
            install @workstation-product-environment
        else
            install gnome-core
        fi
    fi
    if [[ $role == desktop ]]; then
        install gnome-remote-desktop # RDP; connect through an SSH tunnel (see README)
    fi

    context 'Firefox'
    if [[ $distro == debian ]]; then
        # From Mozilla (Debian's is the older ESR), preferred over Debian's package
        apt_repo mozilla https://packages.mozilla.org/apt/repo-signing-key.gpg \
            'deb [signed-by={key}] https://packages.mozilla.org/apt mozilla main'
        run_noeval 'pin packages.mozilla.org > /etc/apt/preferences.d/mozilla'
        printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
            | sudo tee /etc/apt/preferences.d/mozilla > /dev/null
    fi
    install firefox

    context 'Alacritty'
    if [[ $distro == fedora ]]; then
        install alacritty
    else
        # Built with cargo in the langs step (Debian's lags upstream);
        # ncurses-term has its terminfo
        install ncurses-term cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    fi
    [[ $role == desktop ]] && return

    context 'Workstation apps (Flatpak apps come from home/workstation.nix)'
    # steam-devices: udev rules for controllers and VR, which the Steam Flatpak
    # can't install from inside its sandbox
    install flatpak keepassxc virt-manager nvtop steam-devices

    context 'Mullvad VPN'
    if [[ $distro == fedora ]]; then
        [[ -f /etc/yum.repos.d/mullvad.repo ]] ||
            run sudo dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
    else
        apt_repo mullvad https://repository.mullvad.net/deb/mullvad-keyring.asc \
            "deb [signed-by={key} arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable stable main"
    fi
    install mullvad-vpn

    if lspci | grep -qiE 'vga.*nvidia|3d.*nvidia'; then
        context 'NVIDIA driver'
        if [[ $distro == fedora ]]; then
            rpmfusion
            install akmod-nvidia xorg-x11-drv-nvidia-cuda
        else
            # Only the driver (CUDA lives in the distrobox); built by DKMS and signed
            # for Secure Boot like Debian's. The open kernel modules: what NVIDIA
            # recommends from the RTX 20-series (Turing) on
            # NVIDIA's packages don't pull in what DKMS needs to build the module
            nvidia_repo
            install linux-headers-amd64 dkms
            install nvidia-open
        fi
        message 'With Secure Boot, the driver module must be signed (enroll the MOK key) before it loads.'

        context 'NVIDIA container toolkit (GPU in podman/distrobox)'
        if [[ $distro == fedora ]]; then
            [[ -f /etc/yum.repos.d/nvidia-container-toolkit.repo ]] ||
                run "curl -fsSL https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo > /dev/null"
        fi # Debian: in NVIDIA's repository, added above
        # Its nvidia-cdi-refresh units write the GPU's CDI spec (/var/run/cdi) at
        # boot and when the driver changes: nothing to generate here (which would
        # fail anyway until the driver is loaded, after a reboot)
        install nvidia-container-toolkit
        notes+=('NVIDIA: reboot to load the driver (with Secure Boot, enroll the MOK key first).')
    fi
    notes+=('VeraCrypt is not packaged anywhere: download it from veracrypt.io.')
}

# --- home -------------------------------------------------------------------

function step_home() {
    # Single-user installs: the profile is in ~/.local/state/nix once home-manager
    # has set use-xdg-base-directories, ~/.nix-profile before that
    local user_nix_sh=($XDG_STATE_HOME/nix/profile/etc/profile.d/nix.sh(N) $HOME/.nix-profile/etc/profile.d/nix.sh(N))

    context 'Nix'
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh || -n $user_nix_sh ]]; then
        message 'Nix detected. No need to install.'
    elif [[ -d /run/systemd/system ]]; then
        # Determinate Systems' installer: unlike the official one it supports
        # SELinux (Fedora) by installing a policy, and can uninstall cleanly
        # (/nix/nix-installer uninstall). Installs upstream Nix, no diagnostics.
        local confirm=()
        [[ -t 0 ]] || confirm=(--no-confirm) # show the plan and ask when interactive
        # Download first (not curl | sh) so the installer's prompt can read the terminal
        local installer=$(mktemp)
        run curl --proto "'=https'" --tlsv1.2 -sSfL -o $installer https://install.determinate.systems/nix
        run_noeval "sh $installer install --prefer-upstream-nix $confirm"
        NIX_INSTALLER_DIAGNOSTIC_ENDPOINT= sh $installer install --prefer-upstream-nix $confirm
        rm -f $installer
    else
        # No systemd (e.g. a container): single-user install
        run_noeval "curl -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon --yes"
        curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon --yes
    fi
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    else
        user_nix_sh=($XDG_STATE_HOME/nix/profile/etc/profile.d/nix.sh(N) $HOME/.nix-profile/etc/profile.d/nix.sh(N))
        source $user_nix_sh[1]
    fi
    # home/common.nix enables flakes in ~/.config/nix/nix.conf, after the first switch
    export NIX_CONFIG='experimental-features = nix-command flakes'

    context 'Nix configuration'
    # use-xdg-base-directories puts the profile in ~/.local/state/nix (home/common.nix
    # assumes it). It goes in the system config: as a user setting, every command
    # would forward it to the daemon, which warns that it's ignoring it.
    if ! grep -qsE '^\s*use-xdg-base-directories\s*=\s*true' /etc/nix/nix.conf /etc/nix/nix.custom.conf; then
        local nix_conf=/etc/nix/nix.conf
        [[ -f /etc/nix/nix.custom.conf ]] && nix_conf=/etc/nix/nix.custom.conf # Determinate's installer owns nix.conf
        run sudo mkdir -p /etc/nix
        run_noeval "echo 'use-xdg-base-directories = true' | sudo tee -a $nix_conf"
        echo 'use-xdg-base-directories = true' | sudo tee -a $nix_conf > /dev/null
    else
        message 'use-xdg-base-directories is set.'
    fi

    context 'Removing symlinks into the dotfiles repo (home-manager recreates them)'
    local repo=${DOTFILES:A} target
    typeset -A removed # link -> its target, to restore if the switch fails
    for f in $HOME/.config/*(N@) $HOME/.config/zsh/*(N@) $HOME/.bashrc(N@) $HOME/.zshrc(N@); do
        target=$(readlink $f)
        [[ $target == /* ]] || target=${f:h}/$target
        # Resolve only the parent, so links to files deleted from the repo still match.
        # Only direct links (as older setups made), not home-manager's via /nix/store.
        if [[ $target != /nix/store/* && ${target:h:A}/${target:t} == $repo/* ]]; then
            removed[$f]=$(readlink $f)
            run rm $f
        fi
    done

    context "Applying home-manager profile quocanh@$role"
    message 'Existing files in the way are renamed with a .pre-hm suffix.'
    if ! run nix run $DOTFILES#home-manager -- switch -b pre-hm --flake $DOTFILES#quocanh@$role; then
        message 'home-manager failed: restoring the removed symlinks.'
        for f target in ${(kv)removed}; do
            [[ -e $f || -L $f ]] || ln -s $target $f
        done
        exit 1
    fi

    context 'Migrating ~/.nix-profile and ~/.nix-defexpr to ~/.local/state/nix'
    # home/common.nix sets use-xdg-base-directories. Nix's shell setup warns on
    # every new shell while the legacy profile link still exists.
    local state=$XDG_STATE_HOME/nix legacy=$HOME/.nix-profile
    if [[ -L $legacy && -e $state/profile && ${legacy:A} == ${${:-$state/profile}:A} ]]; then
        run rm $legacy
    fi
    # Nix may already have created the XDG defexpr, so merge into it
    if [[ -d $HOME/.nix-defexpr && ! -L $HOME/.nix-defexpr ]]; then
        run mkdir -p $state/defexpr
        for f in $HOME/.nix-defexpr/*(ND); do
            [[ -e $state/defexpr/${f:t} || -L $state/defexpr/${f:t} ]] || run mv $f $state/defexpr/
        done
        run rm -rf $HOME/.nix-defexpr
    fi
    if [[ -f $HOME/.nix-channels && ! -e $state/channels ]]; then
        run mv $HOME/.nix-channels $state/channels
    fi

    if [[ $role != server && ${DOTFILES:A} != ${${:-$XDG_DATA_HOME/dotfiles}:A} ]]; then
        notes+=("Config files link to ~/.local/share/dotfiles: move this checkout there (or symlink it).")
    fi
    notes+=('Open a new shell for the new PATH; log out and back in for environment.d (GUI apps).')
}

# --- langs ------------------------------------------------------------------

function step_langs() {
    if ! (( $+commands[mise] && $+commands[rustup] )); then
        message 'mise or rustup not found: run the home step first.'; exit 1
    fi

    context 'Tools from ~/.config/mise/config.toml'
    # Prebuilt binaries by default, so no compiler or -dev packages are needed
    run mise install

    context 'pnpm (through Node corepack)'
    run mise exec -- corepack enable pnpm

    context 'Rust stable toolchain'
    if rustc --version > /dev/null 2>&1; then
        message "Rust detected: $(rustc --version)"
    else
        run rustup default stable
    fi

    if [[ $distro == debian && $role == (workstation|desktop) ]] && ! (( $+commands[alacritty] )); then
        context 'Alacritty (cargo build: no official Linux binaries, and Debian lags upstream)'
        run cargo install --locked alacritty
        # The desktop entry and icon from the release
        local tag=$(curl -fsSL https://api.github.com/repos/alacritty/alacritty/releases/latest | rg -o '"tag_name": "([^"]+)"' -r '$1')
        local url=https://github.com/alacritty/alacritty/releases/download/$tag
        run mkdir -p $XDG_DATA_HOME/applications $XDG_DATA_HOME/icons/hicolor/scalable/apps
        run curl -fsSLo $XDG_DATA_HOME/applications/Alacritty.desktop $url/Alacritty.desktop
        run curl -fsSLo $XDG_DATA_HOME/icons/hicolor/scalable/apps/Alacritty.svg $url/Alacritty.svg
    fi
}

# --- theme ------------------------------------------------------------------

function step_theme() {
    # gsettings/dconf need a session bus: start one when run over SSH
    if [[ -n $DBUS_SESSION_BUS_ADDRESS ]]; then
        $DOTFILES/theme.sh --current
    else
        dbus-run-session -- $DOTFILES/theme.sh --current
    fi
}

# --- extensions -------------------------------------------------------------

# GNOME Shell loads extensions from these, in order
function extension_installed() {
    local d
    for d in $XDG_DATA_HOME /usr/local/share /usr/share; do
        [[ -d $d/gnome-shell/extensions/$1 ]] && return 0
    done
    return 1
}

function step_extensions() {
    context 'GNOME extensions (enabled in home/gnome.nix)'
    local shell_version=$(gnome-shell --version | rg -o '\d+' | head -1)
    # home-manager wrote the list to dconf in the home step
    local enabled=(${(f)"$(dconf read /org/gnome/shell/enabled-extensions | rg -o "'([^']+)'" -r '$1')"})
    local uuid url zip installed=0
    for uuid in $enabled; do
        if extension_installed $uuid; then
            message "$uuid: installed"
            continue
        fi
        # The latest release that supports this GNOME Shell version
        url=$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version" \
            | jq -r '.download_url // empty') || true
        if [[ -z $url ]]; then
            message "$uuid: no release for GNOME Shell $shell_version on extensions.gnome.org"
            continue
        fi
        zip=$(mktemp --suffix=.zip)
        run curl -fsSLo $zip "'https://extensions.gnome.org$url'"
        run gnome-extensions install --force $zip
        rm -f $zip
        installed=1
    done
    if (( installed )); then
        notes+=('Log out and back in to load the new GNOME extensions (GNOME Shell keeps them updated).')
    fi
}

# --- ssh --------------------------------------------------------------------

DROPIN=/etc/ssh/sshd_config.d/00-hardening.conf

function step_ssh() {
    context 'SSH client key'
    run mkdir -p $HOME/.ssh
    run chmod 700 $HOME/.ssh
    if [[ ! -f $HOME/.ssh/id_ed25519 ]]; then
        run ssh-keygen -t ed25519 -a 100 -f $HOME/.ssh/id_ed25519
    else
        message 'id_ed25519 exists'
    fi

    if [[ $role == workstation ]]; then
        message "The workstation doesn't accept SSH connections."
        # Debian's default zone allows ssh
        if (( $+commands[firewall-cmd] )) && sudo firewall-cmd --permanent --query-service=ssh > /dev/null; then
            run sudo firewall-cmd --permanent --remove-service=ssh
            run sudo firewall-cmd --reload
        fi
        if systemctl is-enabled --quiet sshd 2> /dev/null; then
            notes+=('sshd is enabled on this workstation. Disable it with: sudo systemctl disable --now sshd')
        fi
        return
    fi

    context 'Authorized keys (.ssh/authorized_keys in this repo)'
    run touch $HOME/.ssh/authorized_keys
    run chmod 600 $HOME/.ssh/authorized_keys
    while read key; do
        [[ -n $key ]] || continue
        if ! grep -qxF $key $HOME/.ssh/authorized_keys; then
            run_noeval "append key: ${key##* }"
            print -r -- $key >> $HOME/.ssh/authorized_keys
        fi
    done < $DOTFILES/.ssh/authorized_keys

    context 'SSH server'
    install openssh-server mosh
    getent group ssh-user > /dev/null || run sudo groupadd ssh-user
    if ! id -nG $USER | grep -qw ssh-user; then
        run sudo usermod -a -G ssh-user $USER
        notes+=("Log in again for the ssh-user group to apply to $USER.")
    fi

    # A drop-in, not a replacement sshd_config: the distro's defaults (sftp
    # subsystem, PAM, crypto policy) stay intact. sshd uses the first value it reads
    # for each option, and drop-ins are read in name order, so 00- takes precedence
    # over distro and cloud-init drop-ins (e.g. 50-cloud-init.conf enabling
    # passwords). Algorithms are left at OpenSSH's defaults, which include
    # post-quantum key exchange.
    context "Writing $DROPIN"
    run sudo mkdir -p /etc/ssh/sshd_config.d
    run_noeval "sudo tee $DROPIN"
    sudo tee $DROPIN > /dev/null << 'END'
# Managed by dotfiles/setup.sh
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
AuthenticationMethods publickey
AllowGroups ssh-user
END
    if ! sudo grep -qE '^\s*Include\s+/etc/ssh/sshd_config.d/\*\.conf' /etc/ssh/sshd_config; then
        message "Warning: /etc/ssh/sshd_config doesn't include sshd_config.d/*.conf, so $DROPIN has no effect."
    fi
    run sudo sshd -t # validate before (re)starting

    # Debian names the unit ssh, Fedora sshd
    local unit=sshd
    systemctl list-unit-files ssh.service > /dev/null 2>&1 && unit=ssh
    run sudo systemctl enable --now $unit
    run sudo systemctl reload $unit

    if (( $+commands[firewall-cmd] )); then
        context 'Opening ssh and mosh in firewalld'
        run sudo firewall-cmd --permanent --add-service=ssh --add-service=mosh
        run sudo firewall-cmd --reload
    fi
}

# --- main -------------------------------------------------------------------

# Debian's installer gives the first user sudo only when the root password is left empty
if ! sudo -v; then
    message "$USER can't use sudo. As root (su -): usermod -aG sudo $USER (Fedora: wheel), then log in again."
    exit 1
fi

notes=()
for step in $steps; do
    message "\n==> $step"
    # Steps after home use its tools, also when run on their own
    [[ $step == (langs|extensions) ]] && load_home_env
    step_$step
done

context 'Done'
for n in $notes; do message $n; done
