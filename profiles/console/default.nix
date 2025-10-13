{ config, pkgs, lib, disko, enableSsh, ... }:
{
  imports = [ ../core ];

  virtualisation.podman.enable = true;

  environment.systemPackages = with pkgs; [
    # Common tools
    curl
    git
    neovim
    fd
    ripgrep
    podman

    # TUI tools
    fzf
    helix
    zellij
    starship
    scc
    glow
    tldr
    sccache
    cargo-binstall
    cargo-update
    bandwhich
    bat
    bottom
    difftastic
    dust
    git-delta
    hyperfine
    nushell
    procs
    sd
    tealdeer
    tokei

    # Language toolchains
    python3
    nodejs
    go
    rustc
    cargo

    # Language servers
    rust-analyzer
    gopls
    delve
    goimports
    nodePackages.typescript-language-server
    nodePackages.typescript
    nodePackages.svelte-language-server
    nodePackages.typescript-svelte-plugin
    nodePackages_latest."@tailwindcss/language-server"
    nodePackages.vscode-langservers-extracted
    pyright
    ruff
    black
    lua-language-server
    taplo
    wgsl-analyzer
  ];

    home.file.".config/atuin/config.toml".source = ./../../.config/atuin/config.toml;
    home.file.".config/helix/config.toml".source = ./../../.config/helix/config.toml;
    home.file.".config/helix/languages.toml".source = ./../../.config/helix/languages.toml;
    home.file.".config/nushell/config.nu".source = ./../../.config/nushell/config.nu;
    home.file.".config/nushell/env.nu".source = ./../../.config/nushell/env.nu;
    home.file.".config/nvim/init.lua".source = ./../../.config/nvim/init.lua;
    home.file.".config/powerlevel10k/config.zsh".source = ./../../.config/powerlevel10k/config.zsh;
    home.file.".config/zellij/config.kdl".source = ./../../.config/zellij/config.kdl;
    home.file.".bashrc".source = ./../../.bashrc;
    home.file.".zshrc".source = ./../../.zshrc;

    home.sessionVariables = {
      GOPATH = "$XDG_DATA_HOME/go";
      CARGO_HOME = "$XDG_DATA_HOME/cargo";
      RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    };

    programs.starship.enable = true;
    programs.git.enable = true;
    programs.helix.enable = true;
    programs.neovim.enable = true;
  };
}
