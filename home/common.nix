# Shared by every profile: user, XDG, and how config files are linked.
{ config, lib, ... }:
let
  cfg = config.dotfiles;
in
{
  options.dotfiles = {
    path = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.local/share/dotfiles";
      description = "Dotfiles checkout that live links point to.";
    };
    liveLinks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Link config files to the checkout at `path`, so they can be edited in
        place (and by theme.sh). When false, copy them into the Nix store.
      '';
    };
  };

  config = {
    # `link ".config/helix"` -> source for home.file / xdg.configFile
    _module.args.link = path:
      if cfg.liveLinks
      then config.lib.file.mkOutOfStoreSymlink "${cfg.path}/${path}"
      else ../. + "/${path}";

    home.username = "quocanh";
    home.homeDirectory = "/home/quocanh";
    home.stateVersion = "26.05";

    # Not NixOS: set up XDG_DATA_DIRS etc. for Nix-installed apps
    targets.genericLinux.enable = true;
    # GUI apps come from apt/Flatpak, so skip the Nix GPU driver setup check
    targets.genericLinux.gpu.enable = false;
    xdg.enable = true;
    home.preferXdgDirectories = true;

    programs.home-manager.enable = true;
    news.display = "silent";
    # Flakes for `home-manager switch --flake` (Nix itself comes from the system install)
    xdg.configFile."nix/nix.conf".text = "experimental-features = nix-command flakes\n";
  };
}
