#! /usr/bin/zsh
source $(dirname $0)/_lib.sh
localrc="$XDG_CONFIG_HOME/localrc"

context "Install prerequisites"
run sudo dnf install perl

context "Install tools"
run sudo dnf install fzf helix
run cargo install sccache
run cargo install \
  bandwhich \
  bat \
  bottom \
  difftastic \
  du-dust \
  git-delta \
  hyperfine \
  nu \
  procs \
  rink \
  sd \
  starship \
  tealdeer \
  tokei \
  zellij
run unique_append $localrc << "END"
# Customize prompt with Starship
(! command -v starship > /dev/null) || eval "$(starship init $(basename $SHELL))"
END
run go install github.com/charmbracelet/glow@latest

context "Installing language servers"
run mkdir -p $HOME/ws/3p
run pushd $HOME/ws/3p

message "C/C++: clangd"
run sudo dnf install clang-tools-extra

message "Rust: rust-analyzer"
run git clone https://github.com/rust-lang/rust-analyzer.git
run pushd rust-analyzer
run cargo xtask install --server
run popd

message "Go: gopls (LSP) + delve (debugger) + goimports (formatter)"
go install golang.org/x/tools/gopls@latest          # LSP
go install github.com/go-delve/delve/cmd/dlv@latest # Debugger
go install golang.org/x/tools/cmd/goimports@latest  # Formatter

message "Javascript/Typescript: typescript-language-server"
run pnpm install -g typescript-language-server typescript
message "SvelteJS: svelte-language-tools"
run pnpm install -g svelte-language-server typescript-svelte-plugin
message "TailwindCSS: tailwindcss-ls"
run pnpm install -g @tailwindcss/language-server
message "HTML+JSON: vscode-langservers-extracted"
run pnpm install -g vscode-langservers-extracted

message "Python: pyright (autocompletion) + ruff (linter) + black (formatting)"
pip install --user pyright ruff black

message "Lua: lua-language-server"
run git clone https://github.com/LuaLS/lua-language-server
run pushd lua-language-server
run sh make.sh
run popd

message "TOML: taplo"
run cargo install taplo-cli --features lsp

message "WGSL: wgsl_analyzer"
run cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer wgsl_analyzer

run popd
