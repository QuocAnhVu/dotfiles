# Desktops (local and remote): terminal config and fonts.
# GUI apps (alacritty, browsers, keepassxc) come from apt/Flatpak: Nix-built GUI
# apps can't find the system's GPU drivers on non-NixOS.
{ pkgs, link, ... }:
{
  imports = [ ./full.nix ];

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.enable = true;

  xdg.configFile."alacritty".source = link ".config/alacritty";
}
