# Headless servers: shell config and a small set of tools for debugging.
{ lib, pkgs, link, ... }:
{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    bat
    bottom
    delta
    dust
    fd
    fzf
    git
    helix
    jq
    mosh # mosh-server, for connecting with mosh
    procs
    ripgrep
    starship
  ];

  home.file.".bashrc".source = link ".bashrc";
  # Link the file, not the directory, so zsh's own files (.zcompdump) stay out of the repo
  xdg.configFile."zsh/.zshenv".source = link ".config/zsh/.zshenv";
  xdg.configFile."zsh/.zshrc".source = link ".config/zsh/.zshrc";
  xdg.configFile."helix".source = link ".config/helix";
  # Directory links: `git config --global` and `mise use -g` replace the file
  # rather than editing it, which would turn a file link into a plain file
  xdg.configFile."git".source = link ".config/git";

  # Neovim without plugins here; full.nix adds them. init.lua skips plugin
  # setup when a plugin isn't installed.
  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    sideloadInitLua = true; # keep ~/.config/nvim/init.lua ours (linked below)
  };
  xdg.configFile."nvim/init.lua" = {
    source = link ".config/nvim/init.lua";
    # The neovim module disables this entry when sideloading its own init.lua
    enable = lib.mkForce true;
  };
  xdg.configFile."starship.toml".source = link ".config/starship.toml";
}
