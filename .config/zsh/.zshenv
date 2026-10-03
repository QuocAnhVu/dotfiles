# Environment for every zsh, interactive or not, including the login shell GDM
# starts the desktop session with. That shell runs before Fedora's
# /etc/profile.d, which only sets variables like EDITOR when they're unset.
# Interactive settings are in .zshrc.

# Nix and home-manager: packages on PATH, session variables (EDITOR, XDG...)
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -e "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/etc/profile.d/nix.sh" ]; then
    . "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/etc/profile.d/nix.sh"
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
# hm-session-vars.sh skips itself when __HM_SESS_VARS_SOURCED is set. A login
# shell starts a session (desktop, SSH, TTY): load it again regardless. The
# user's systemd manager can outlive a logout (a process left running) and
# hand the old session's marker to the next login, which then kept old values.
[[ -o login ]] && unset __HM_SESS_VARS_SOURCED
for hm_vars in "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile" "$HOME/.nix-profile"; do
    hm_vars="$hm_vars/etc/profile.d/hm-session-vars.sh"
    [ -r "$hm_vars" ] && { . "$hm_vars"; break; }
done
unset hm_vars

# Machine-specific variables (environment.d format, not in git). The desktop
# session already has them; this covers TTY and SSH shells.
local_env=${XDG_CONFIG_HOME:-$HOME/.config}/environment.d/90-local.conf
if [[ -r $local_env ]]; then
    while IFS='=' read -r key value; do
        [[ -z $key || $key == \#* ]] && continue
        export $key=${(e)value} # expand ${VAR} like systemd does
    done < $local_env
fi
unset local_env key value
typeset -U path # drop duplicate PATH entries
