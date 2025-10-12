{
  imports = [ ./../nixos/hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.quocanh = {
    isNormalUser = true;
    description = "Quoc Anh";
    extraGroups = [ "wheel" "ssh-user" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [];

  security.hardening.enable = true;

  home-manager.users.quocanh = {
    home.username = "quocanh";
    home.homeDirectory = "/home/quocanh";

    home.sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    };

    home.stateVersion = "23.11";
  };

  system.stateVersion = "23.11";
}
