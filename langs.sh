#! /usr/bin/zsh
# Install language toolchains: the versions in .config/mise/config.toml (Python,
# Node, Go, Lua), pnpm, and the Rust stable toolchain. mise and rustup come from
# home-manager (./home.sh dev or desktop). Safe to rerun.
source $(dirname $0)/_lib.sh
setopt err_exit

if ! (( $+commands[mise] && $+commands[rustup] )); then
    message 'mise or rustup not found: run ./home.sh dev (or desktop) first, then open a new shell.'
    exit 1
fi

context 'Installing tools from ~/.config/mise/config.toml'
# Prebuilt binaries by default, so no compiler or -dev packages are needed
run mise install

context 'Enabling pnpm (through Node corepack)'
run mise exec -- corepack enable pnpm

context 'Installing the Rust stable toolchain'
if rustc --version > /dev/null 2>&1; then
    message "Rust detected: $(rustc --version)"
else
    run rustup default stable
fi
