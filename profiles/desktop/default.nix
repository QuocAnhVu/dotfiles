{ pkgs, ... }:
{
  imports = [ ./console ];

  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    chromium
    cosmic-desktop
    cryptomator
    keepassxc
  ];

  services.cosmic-greeter.enable = true;
  services.cosmic-session.enable = true;

  home-manager.users.quocanh = {
    home.packages = with pkgs; [
      nerdfonts
    ];

    home.file.".config/alacritty/alacritty.toml".source = ./../../.config/alacritty/alacritty.toml;

    programs.alacritty.enable = true;
    programs.keepassxc = {
      enable = true;
      browserIntegration = true;
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