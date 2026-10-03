#! /usr/bin/zsh
# System packages: what doesn't come from Nix (home-manager) or Flatpak
# (nix-flatpak). Debian or Fedora. Safe to rerun.
#   dev:         build tools
#   desktop:     + GNOME (if missing) with RDP, Firefox, Alacritty (remote desktops)
#   workstation: + KeePassXC, virt-manager, nvtop, Performous, Mullvad, NVIDIA
# Usage: ./packages.sh <workstation|desktop|dev|server>
source $(dirname $0)/_lib.sh
setopt err_exit

role=$1
case $role in
    workstation | desktop | dev | server) ;;
    *) echo "Usage: $0 <workstation|desktop|dev|server>"; exit 1 ;;
esac
if rg --quiet '^ID=fedora' /etc/os-release; then
    distro=fedora
elif rg --quiet '^ID=debian' /etc/os-release; then
    distro=debian
else
    message 'Only Debian and Fedora are supported.'; exit 1
fi
has_nvidia=$( (lspci 2> /dev/null || true) | rg --quiet -i 'vga.*nvidia|3d.*nvidia' && echo 1 || echo 0)

function install() {
    if [[ $distro == fedora ]]; then
        run sudo dnf install -y $@
    else
        run sudo apt-get install -y $@
    fi
}

# Adds an apt repository: name, key URL, "deb ..." line ({key} is replaced by the key path)
function apt_repo() {
    local name=$1 key_url=$2 line=$3 key=/etc/apt/keyrings/$1.asc
    [[ -f /etc/apt/sources.list.d/$name.list ]] && return
    run sudo install -d -m 0755 /etc/apt/keyrings
    run sudo curl -fsSLo $key $key_url
    run_noeval "${line//\{key\}/$key} > /etc/apt/sources.list.d/$name.list"
    print -r -- ${line//\{key\}/$key} | sudo tee /etc/apt/sources.list.d/$name.list > /dev/null
    run sudo apt-get update
}

if [[ $role == server ]]; then
    message 'Servers need nothing beyond base.sh and harden.sh.'
    exit 0
fi

context 'Build tools (Nix versions of cmake/meson/clangd do not see system libraries)'
if [[ $distro == fedora ]]; then
    install gcc gcc-c++ make cmake meson pkgconf-pkg-config clang-tools-extra
else
    install build-essential cmake meson pkg-config clangd
fi

[[ $role == dev ]] && exit 0

# RPM Fusion: Performous, the NVIDIA driver, multimedia codecs
function rpmfusion() {
    local v=$(rpm -E %fedora)
    rpm --quiet -q rpmfusion-nonfree-release || run sudo dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$v.noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$v.noarch.rpm
    # Fedora's codec-limited ffmpeg libraries conflict with RPM Fusion's, which
    # its packages (Performous) need: switch to the full ffmpeg (RPM Fusion's documented step)
    rpm --quiet -q ffmpeg || run sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
}

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
if [[ $distro == fedora ]]; then
    install firefox
else
    # From Mozilla (Debian's is the older ESR), preferred over Debian's package
    apt_repo mozilla https://packages.mozilla.org/apt/repo-signing-key.gpg \
        'deb [signed-by={key}] https://packages.mozilla.org/apt mozilla main'
    run_noeval 'pin packages.mozilla.org > /etc/apt/preferences.d/mozilla'
    printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
        | sudo tee /etc/apt/preferences.d/mozilla > /dev/null
    install firefox
fi

context 'Alacritty'
if [[ $distro == fedora ]]; then
    install alacritty
elif ! (( $+commands[alacritty] )); then
    # Debian's lags upstream: build it (there are no official Linux binaries)
    # and install the desktop entry and icon from the release; ncurses-term has its terminfo
    install ncurses-term cmake g++ pkg-config libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    run cargo install --locked alacritty
    tag=$(curl -fsSL https://api.github.com/repos/alacritty/alacritty/releases/latest | rg -o '"tag_name": "([^"]+)"' -r '$1')
    url=https://github.com/alacritty/alacritty/releases/download/$tag
    run mkdir -p $XDG_DATA_HOME/applications $XDG_DATA_HOME/icons/hicolor/scalable/apps
    run curl -fsSLo $XDG_DATA_HOME/applications/Alacritty.desktop $url/Alacritty.desktop
    run curl -fsSLo $XDG_DATA_HOME/icons/hicolor/scalable/apps/Alacritty.svg $url/Alacritty.svg
fi

[[ $role == desktop ]] && exit 0

context 'Workstation apps (Flatpak apps come from home/workstation.nix)'
if [[ $distro == fedora ]]; then
    rpmfusion
fi
install flatpak keepassxc virt-manager nvtop performous

context 'Mullvad VPN'
if [[ $distro == fedora ]]; then
    [[ -f /etc/yum.repos.d/mullvad.repo ]] ||
        run sudo dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
else
    apt_repo mullvad https://repository.mullvad.net/deb/mullvad-keyring.asc \
        "deb [signed-by={key} arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable stable main"
fi
install mullvad-vpn

if (( has_nvidia )); then
    context 'NVIDIA driver'
    if [[ $distro == fedora ]]; then
        rpmfusion
        install akmod-nvidia xorg-x11-drv-nvidia-cuda
    else
        # Needs the contrib, non-free and non-free-firmware components enabled
        install nvidia-driver firmware-misc-nonfree
    fi
    message 'With Secure Boot, the driver module must be signed (enroll the MOK key) before it loads.'

    context 'NVIDIA container toolkit (GPU in podman/distrobox)'
    if [[ $distro == fedora ]]; then
        [[ -f /etc/yum.repos.d/nvidia-container-toolkit.repo ]] ||
            run "curl -fsSL https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo > /dev/null"
    else
        apt_repo nvidia-container-toolkit https://nvidia.github.io/libnvidia-container/gpgkey \
            'deb [signed-by={key}] https://nvidia.github.io/libnvidia-container/stable/deb/$(ARCH) /'
    fi
    install nvidia-container-toolkit
    run sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
fi

context 'Done'
message 'Not packaged anywhere: VeraCrypt (download from veracrypt.io).'
message 'Flatpak apps come from home-manager (home/workstation.nix).'
