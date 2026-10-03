# Desktops (remote and the workstation): terminal config, fonts, distrobox.
# GUI apps (alacritty, browsers, keepassxc) come from apt/Flatpak: Nix-built GUI
# apps can't find the system's GPU drivers on non-NixOS.
{ pkgs, link, ... }:
{
  imports = [ ./full.nix ];

  home.packages = with pkgs; [
    distrobox # containers with a different distro, sharing $HOME (uses the system podman)
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.enable = true;

  xdg.configFile."alacritty".source = link ".config/alacritty";
}
