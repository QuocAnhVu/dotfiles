# Interactive shells. Environment variables are set in .zshenv (from
# home-manager: home/*.nix, plus ~/.config/environment.d/90-local.conf).
export LANG=en_US.UTF-8

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

# Secrets (API keys) for interactive shells only, so they stay out of the
# desktop session: KEY=VALUE lines in an untracked file
if [[ -r $XDG_CONFIG_HOME/secrets.env ]]; then
    while IFS='=' read -r key value; do
        [[ -z $key || $key == \#* ]] || export $key=$value
    done < $XDG_CONFIG_HOME/secrets.env
    unset key value
fi

# Google Cloud SDK completion, if installed
[[ ! -r $XDG_DATA_HOME/google-cloud-sdk/completion.zsh.inc ]] || source $XDG_DATA_HOME/google-cloud-sdk/completion.zsh.inc
