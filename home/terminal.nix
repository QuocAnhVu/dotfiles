# The terminal session: zellij, with nushell as its shell (Alacritty starts
# zellij). For desktops and dev machines.
{ pkgs, link, ... }:
{
  home.packages = with pkgs; [
    nushell
    zellij
  ];

  xdg.configFile."nushell".source = link ".config/nushell";
  xdg.configFile."zellij".source = link ".config/zellij";
}
