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
    home.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    fonts.fontconfig.enable = true;

    home.file.".config/alacritty/alacritty.toml".source = ./../../.config/alacritty/alacritty.toml;

    programs.alacritty.enable = true;
    programs.keepassxc = {
      enable = true;
      settings = {
        Browser = {
          Enabled = true;
        };
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
      profiles.default.extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          violentmonkey
          vimium
        ];
      };
    };
  };
}
