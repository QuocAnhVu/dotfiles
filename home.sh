#! /usr/bin/zsh
# Install Nix if needed, then apply a home-manager profile from this repo.
# Usage: ./home.sh <workstation|desktop|dev|server>
source $(dirname $0)/_lib.sh
setopt err_exit

DOTFILES=$(cd $(dirname $0) && pwd)
profile=$1
case $profile in
    workstation | desktop | dev | server) ;;
    *) echo "Usage: $0 <workstation|desktop|dev|server>"; exit 1 ;;
esac

# Single-user installs: the profile is in ~/.local/state/nix once home-manager
# has set use-xdg-base-directories, ~/.nix-profile before that
user_nix_sh=(${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/etc/profile.d/nix.sh(N) $HOME/.nix-profile/etc/profile.d/nix.sh(N))

context 'Installing Nix'
if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh || -n $user_nix_sh ]]; then
    message 'Nix detected. No need to install.'
elif [[ -d /run/systemd/system ]]; then
    # Determinate Systems' installer: unlike the official one it supports
    # SELinux (Fedora) by installing a policy, and can uninstall cleanly
    # (/nix/nix-installer uninstall). Installs upstream Nix, no diagnostics.
    confirm=()
    [[ -t 0 ]] || confirm=(--no-confirm) # show the plan and ask when interactive
    # Download first (not curl | sh) so the installer's prompt can read the terminal
    installer=$(mktemp)
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
    user_nix_sh=(${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/etc/profile.d/nix.sh(N) $HOME/.nix-profile/etc/profile.d/nix.sh(N))
    source $user_nix_sh[1]
fi
# home/common.nix enables flakes in ~/.config/nix/nix.conf, after the first switch
export NIX_CONFIG='experimental-features = nix-command flakes'

context 'Configuring Nix'
# use-xdg-base-directories puts the profile in ~/.local/state/nix (home/common.nix
# assumes it). It goes in the system config: as a user setting, every command
# would forward it to the daemon, which warns that it's ignoring it.
if ! grep -qsE '^\s*use-xdg-base-directories\s*=\s*true' /etc/nix/nix.conf /etc/nix/nix.custom.conf; then
    nix_conf=/etc/nix/nix.conf
    [[ -f /etc/nix/nix.custom.conf ]] && nix_conf=/etc/nix/nix.custom.conf # Determinate's installer owns nix.conf
    run sudo mkdir -p /etc/nix
    run_noeval "echo 'use-xdg-base-directories = true' | sudo tee -a $nix_conf"
    echo 'use-xdg-base-directories = true' | sudo tee -a $nix_conf > /dev/null
else
    message 'use-xdg-base-directories is set.'
fi

context 'Removing symlinks into the dotfiles repo (home-manager recreates them)'
repo=${DOTFILES:A}
typeset -A removed # link -> its target, to restore if the switch fails
for f in $HOME/.config/*(N@) $HOME/.config/zsh/*(N@) $HOME/.bashrc(N@) $HOME/.zshrc(N@); do
    target=$(readlink $f)
    [[ $target == /* ]] || target=${f:h}/$target
    # Resolve only the parent, so links to files deleted from the repo still match.
    # Only direct links (as base.sh makes), not home-manager's via /nix/store.
    if [[ $target != /nix/store/* && ${target:h:A}/${target:t} == $repo/* ]]; then
        removed[$f]=$(readlink $f)
        run rm $f
    fi
done

context "Applying home-manager profile quocanh@$profile"
message 'Existing files in the way are renamed with a .pre-hm suffix.'
if ! run nix run $DOTFILES#home-manager -- switch -b pre-hm --flake $DOTFILES#quocanh@$profile; then
    message 'home-manager failed: restoring the removed symlinks.'
    for f target in ${(kv)removed}; do
        [[ -e $f || -L $f ]] || ln -s $target $f
    done
    exit 1
fi

context 'Migrating ~/.nix-profile and ~/.nix-defexpr to ~/.local/state/nix'
# home/common.nix sets use-xdg-base-directories. Nix's shell setup warns on
# every new shell while the legacy profile link still exists.
state=${XDG_STATE_HOME:-$HOME/.local/state}/nix
legacy=$HOME/.nix-profile
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

context 'Done'
message 'Open a new shell to pick up the new PATH.'
if [[ $profile != server ]]; then
    message "Config files link to ~/.local/share/dotfiles: keep the checkout there (or a symlink to it)."
fi
