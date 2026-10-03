# Desktops (remote and the workstation): the server tools (for SSHing in),
# terminal config, fonts, distrobox. Not the dev suite (full.nix).
# GUI apps (alacritty, browsers, keepassxc) come from apt/Flatpak: Nix-built GUI
# apps can't find the system's GPU drivers on non-NixOS.
{ pkgs, link, ... }:
{
  imports = [ ./minimal.nix ./terminal.nix ];

  home.packages = with pkgs; [
    distrobox # containers with a different distro, sharing $HOME (uses the system podman)
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.enable = true;

  xdg.configFile."alacritty".source = link ".config/alacritty";
}
