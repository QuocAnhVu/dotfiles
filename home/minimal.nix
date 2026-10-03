# Headless servers: shell config and a small set of tools for debugging.
{ pkgs, link, ... }:
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
    neovim
    procs
    ripgrep
    starship
  ];

  home.file.".bashrc".source = link ".bashrc";
  home.file.".zshrc".source = link ".zshrc";
  xdg.configFile."helix".source = link ".config/helix";
  xdg.configFile."starship.toml".source = link ".config/starship.toml";
}
