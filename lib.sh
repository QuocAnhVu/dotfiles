#! /usr/bin/zsh

ORANGE='\e[0;33m'
CYAN='\e[0;36m'
CYAN_ITALIC='\e[3;36m'
GREEN_BOLD='\e[1;32m'
NC='\e[0m'
function context() {
    echo "\n$ORANGE${@:1}$NC"
}
function message() {
    echo "$ORANGE${@:1}$NC"
}
function run_noeval() {
    echo "$CYAN${@:1}$NC"
}
function run() {
    echo "$CYAN${@:1}$NC"
    eval ${@:1}
}
function prompt() {
    echo -n "$GREEN_BOLD$1$NC"
    read -e response
}
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
function unique_append() {
    read -r -d '' MSG
    rg --quiet --fixed-strings --multiline $MSG $1 || echo "$MSG\n" >> $1
}

