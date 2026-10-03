# .bashrc
# Environment variables come from home-manager (home/*.nix) and
# ~/.config/environment.d/90-local.conf, loaded below.

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

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

# Machine-specific variables (environment.d format, not in git). The desktop
# session already has them; this covers TTY and SSH shells.
local_env=${XDG_CONFIG_HOME:-$HOME/.config}/environment.d/90-local.conf
if [ -r "$local_env" ]; then
    while IFS='=' read -r key value; do
        case $key in ''|\#*) continue ;; esac
        export "$key=$(eval "printf '%s' \"$value\"")" # expand ${VAR} like systemd does
    done < "$local_env"
fi
unset local_env key value

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# History
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
mkdir -p "$(dirname "$HISTFILE")"
export HISTFILESIZE=65536
export HISTSIZE=65536

alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'
alias vi=nvim
alias l=ls
alias pn=pnpm

# Prompt and toolchain manager (installed by home-manager)
command -v starship > /dev/null && eval "$(starship init bash)"
command -v mise > /dev/null && eval "$(mise activate bash)"

# Secrets (API keys) for interactive shells only: KEY=VALUE lines, untracked
if [ -r "$XDG_CONFIG_HOME/secrets.env" ]; then
    while IFS='=' read -r key value; do
        case $key in ''|\#*) ;; *) export "$key=$value" ;; esac
    done < "$XDG_CONFIG_HOME/secrets.env"
    unset key value
fi
