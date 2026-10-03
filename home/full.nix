# Headless dev environments: the full CLI/TUI suite and language servers.
# Toolchains stay with mise (python, node, go) and rustup (rust), installed here.
{ config, pkgs, lib, link, ... }:
{
  imports = [ ./minimal.nix ];

  home.packages = with pkgs; [
    # CLI/TUI tools
    bandwhich
    difftastic
    eza
    git-lfs
    glow
    grex
    hyperfine
    iftop
    just
    nmap
    nushell
    pandoc
    parallel
    rink
    sd
    tealdeer
    tokei
    trash-cli
    typst
    yamllint
    zellij

    # Build tools. Not cmake/meson: Nix's builds don't search /usr, so they
    # can't find apt's -dev libraries; install those (and clangd) with apt.
    bazelisk
    ccache
    mold
    ninja
    sccache

    # Cargo subcommands
    cargo-bloat
    cargo-deny
    cargo-flamegraph
    cargo-machete
    cargo-tarpaulin
    cargo-udeps
    cargo-watch

    # Toolchain managers
    mise
    rustup
    uv

    # Language servers and formatters (see .config/helix/languages.toml)
    black
    bun
    dockerfile-language-server
    lua-language-server
    pyright
    ruff
    (lib.hiPrio rust-analyzer) # rustup ships a rust-analyzer proxy too; prefer this one
    svelte-language-server
    tailwindcss-language-server
    taplo
    tinymist
    typescript
    typescript-language-server
    vscode-langservers-extracted
    wgsl-analyzer
  ];

  # Absolute paths: hm-session-vars.sh sets these before XDG_DATA_HOME
  home.sessionVariables = {
    GOPATH = "${config.xdg.dataHome}/go";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
  };

  xdg.configFile."nushell".source = link ".config/nushell";
  xdg.configFile."nvim".source = link ".config/nvim";
  xdg.configFile."zellij".source = link ".config/zellij";
}
