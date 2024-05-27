# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

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

# Customize history
export HISTFILE="$XDG_STATE_HOME/bash/history"
export HISTFILESIZE=65536
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

# Customize prompt with Starship
(! command -v starship > /dev/null) || eval "$(starship init $(basename $SHELL))"

# Set default editor to nvim
export EDITOR=nvim
alias vi=nvim

# Local (untracked) config
[[ ! -r $XDG_CONFIG_HOME/localrc ]] || source $XDG_CONFIG_HOME/localrc
