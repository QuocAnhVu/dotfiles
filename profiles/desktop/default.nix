{ config, pkgs, lib, disko, enableSsh, ... }:
{
  imports = [ ../console ];

  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    chromium
    cryptomator
    keepassxc
  ];

  # Enable the COSMIC login manager
  services.displayManager.cosmic-greeter.enable = true;

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic.enable = true;

  home-manager.users.quocanh = {
    home.packages = with pkgs; [
      nerdfonts
    ];

    home.file.".config/alacritty/alacritty.toml".source = ./../../.config/alacritty/alacritty.toml;

    programs.alacritty.enable = true;
    programs.keepassxc = {
      enable = true;
      browser = {
        enable = true; # <-- The CORRECT option
      };
    };

    programs.chromium = {
      enable = true;
      extensions = [
        { id = "ddbjnfjiigjmcpcpkmhogomapikjbjdk"; } # uBlock Origin Lite
        { id = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; } # Tampermonkey
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
      ];
    };

    programs.firefox = {
      enable = true;
      profiles.default.extensions = with pkgs.firefox-addons; [
        ublock-origin
        tampermonkey
        vimium
      ];
    };
  };
}
