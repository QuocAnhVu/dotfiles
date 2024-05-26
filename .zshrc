export LANG=en_US.UTF-8
# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Custom functions in ~/.zsh_functions
fpath+=${ZDOTDIR:-~}/.zsh_functions

# Customize history
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=65536

# XDG Basedir
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
# XDG Fixes
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
alias wget=wget --hsts-file="$XDG_STATE_HOME/wget-hsts" 
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"

# oh-my-zsh + Powerlevel10k
[[ ! -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] || source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
plugins=(git mise)
ZSH_THEME="powerlevel10k/powerlevel10k"
HIST_STAMPS="yyyy-mm-dd"
export ZSH_COMPDUMP=$XDG_CACHE_HOME/oh-my-zsh/zcompdump-$HOST
DISABLE_AUTO_UPDATE=true
[[ ! -r $XDG_DATA_HOME/oh-my-zsh/oh-my-zsh.sh ]] || source $XDG_DATA_HOME/oh-my-zsh/oh-my-zsh.sh
POWERLEVEL9K_CONFIG_FILE=$XDG_CONFIG_HOME/powerlevel10k/config.zsh
[[ ! -r $XDG_CONFIG_HOME/powerlevel10k/config.zsh ]] || source $XDG_CONFIG_HOME/powerlevel10k/config.zsh

# Aliases
export EDITOR=nvim
alias vi=nvim
alias sprunge="curl -F 'sprunge=<-' http://sprunge.us"

# Local (untracked) config
[[ ! -r $XDG_CONFIG_HOME/localrc ]] || source $XDG_CONFIG_HOME/localrc
