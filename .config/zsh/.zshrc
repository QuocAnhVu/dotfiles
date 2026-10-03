# Environment variables (XDG fixes, EDITOR, PATH) come from home-manager:
# home/common.nix and home/full.nix. This file is for interactive shells.
export LANG=en_US.UTF-8

# Nix and home-manager: packages on PATH, session variables
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -e "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/etc/profile.d/nix.sh" ]; then
    . "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/etc/profile.d/nix.sh"
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
for hm_vars in "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile" "$HOME/.nix-profile"; do
    hm_vars="$hm_vars/etc/profile.d/hm-session-vars.sh"
    [ -r "$hm_vars" ] && { . "$hm_vars"; break; }
done
unset hm_vars

# Custom functions in $ZDOTDIR/.zsh_functions
fpath+=${ZDOTDIR:-~}/.zsh_functions

# History (SAVEHIST: zsh only writes HISTFILE when it's non-zero)
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=65536
SAVEHIST=65536
setopt INC_APPEND_HISTORY # write each command as it runs, not on exit

alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'
alias vi=nvim
alias l='ls -al'
alias pn=pnpm

# Prompt and toolchain manager (installed by home-manager)
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# Local (untracked) config: machine-specific settings and secrets
[[ ! -r $XDG_CONFIG_HOME/localrc ]] || source $XDG_CONFIG_HOME/localrc

# uv/cargo installer env, if present
[ ! -r "$HOME/.local/bin/env" ] || . "$HOME/.local/bin/env"
