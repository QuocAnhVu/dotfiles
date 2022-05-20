# XDG Basedir
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

export EDITOR=nvim
alias vim=nvim
alias exa="exa --header --extended --all --classify --color-scale --long --git --icons --tree --level=1" 

# XDG Extra
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts" 

# CUDA
# export PATH=/usr/local/cuda-11.6/bin${PATH:+:${PATH}}
# export LD_LIBRARY_PATH=/usr/local/cuda-11.6/lib64\
#                          ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# asdf
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"
. $ASDF_DATA_DIR/asdf.sh

# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PATH="$CARGO_HOME/bin":$PATH
export RUSTC_WRAPPER="$CARGO_HOME/bin/sccache"

# # Deno
# export DENO_INSTALL="$HOME/.deno"
# export PATH="$DENO_INSTALL/bin:$PATH"

# Haskell
export PATH=$HOME/.ghcup/bin:$PATH

# External Cache
export TRANSFORMERS_CACHE="/mnt/d/.cache/huggingface/"

# Go
export GOPATH="$XDG_DATA_HOME/go"
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Zsh
export ZSH="$XDG_CONFIG_HOME/oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
HIST_STAMPS="yyyy-mm-dd"
export ZSH_COMPDUMP=$XDG_CACHE_HOME/oh-my-zsh/zcompdump-$HOST

plugins=(git asdf)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
POWERLEVEL9K_CONFIG_FILE=$XDG_CONFIG_HOME/powerlevel10k/config.zsh
[[ ! -f $XDG_CONFIG_HOME/powerlevel10k/config.zsh ]] || source $XDG_CONFIG_HOME/powerlevel10k/config.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/usr/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/usr/etc/profile.d/conda.sh" ]; then
#         . "/usr/etc/profile.d/conda.sh"
#     else
#         export PATH="/usr/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<


# export WASMTIME_HOME="$HOME/.wasmtime"

# export PATH="$WASMTIME_HOME/bin:$PATH"
fpath+=${ZDOTDIR:-~}/.zsh_functions
