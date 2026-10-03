#! /usr/bin/zsh
# Install Nix if needed, then apply a home-manager profile from this repo.
# Usage: ./home.sh <desktop|dev|server>
source $(dirname $0)/_lib.sh
setopt err_exit

DOTFILES=$(cd $(dirname $0) && pwd)
profile=$1
case $profile in
    desktop | dev | server) ;;
    *) echo "Usage: $0 <desktop|dev|server>"; exit 1 ;;
esac

context 'Installing Nix'
if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh || -e $HOME/.nix-profile/etc/profile.d/nix.sh ]]; then
    message 'Nix detected. No need to install.'
elif [[ -d /run/systemd/system ]]; then
    run_noeval "curl -sSfL https://nixos.org/nix/install | sh -s -- --daemon --yes"
    curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --daemon --yes
else
    # No systemd (e.g. a container): single-user install
    run_noeval "curl -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon --yes"
    curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon --yes
fi
if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    source $HOME/.nix-profile/etc/profile.d/nix.sh
fi
export NIX_CONFIG='experimental-features = nix-command flakes'

context 'Removing symlinks into the dotfiles repo (home-manager recreates them)'
repo=${DOTFILES:A}
typeset -A removed # link -> its target, to restore if the switch fails
for f in $HOME/.config/*(N@) $HOME/.bashrc(N@) $HOME/.zshrc(N@); do
    # Only direct links (as base.sh makes), not home-manager's via /nix/store
    if [[ $(readlink $f) != /nix/store/* && ${f:A} == $repo/* ]]; then
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

context 'Done'
message 'Open a new shell to pick up the new PATH.'
if [[ $profile != server ]]; then
    message "Config files link to ~/.local/share/dotfiles: keep the checkout there (or a symlink to it)."
fi
