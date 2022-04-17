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

# CUDA
# export PATH=/usr/local/cuda-11.6/bin${PATH:+:${PATH}}
# export LD_LIBRARY_PATH=/usr/local/cuda-11.6/lib64\
#                          ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# asdf
. $HOME/.asdf/asdf.sh

# Rust
export RUSTC_WRAPPER=/home/quocanh/.cargo/bin/sccache
export PATH=/home/quocanh/.cargo/bin:$PATH

# # Deno
# export DENO_INSTALL="/home/quocanh/.deno"
# export PATH="$DENO_INSTALL/bin:$PATH"

# Haskell
export PATH=/home/quocanh/.ghcup/bin:$PATH

# External Cache
export TRANSFORMERS_CACHE="/mnt/d/.cache/huggingface/"

# Go
export PATH=$PATH:/usr/local/go/bin

export ZSH="/home/quocanh/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
HIST_STAMPS="yyyy-mm-dd"

alias code="flatpak run com.visualstudio.code"
alias vim=nvim
alias exa="exa --header --extended --all --classify --color-scale --long --git --icons --tree --level=1" 

plugins=(git asdf)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
