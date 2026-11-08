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

# Ctrl+arrows (bash gets them from /etc/inputrc; zsh has no binding, and types
# the end of the key's sequence, ";5D"): word left and right, history up and down
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5A' up-line-or-history
bindkey '^[[1;5B' down-line-or-history

alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'
alias vi=nvim
alias l='ls -al'
alias pn=pnpm

# Prompt and toolchain manager (installed by home-manager)
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)" # per-project .envrc (Nix dev shells)

# Secrets (API keys) for interactive shells only, so they stay out of the
# desktop session: KEY=VALUE lines in an untracked file
if [[ -r $XDG_CONFIG_HOME/secrets.env ]]; then
    while IFS='=' read -r key value; do
        [[ -z $key || $key == \#* ]] || export $key=$value
    done < $XDG_CONFIG_HOME/secrets.env
    unset key value
fi

# Aliases and functions for this machine only, in an untracked file (shared
# with bash; nushell's are in local.nu)
[[ ! -r $XDG_CONFIG_HOME/local.sh ]] || source $XDG_CONFIG_HOME/local.sh

# Google Cloud SDK completion, if installed
[[ ! -r $XDG_DATA_HOME/google-cloud-sdk/completion.zsh.inc ]] || source $XDG_DATA_HOME/google-cloud-sdk/completion.zsh.inc
