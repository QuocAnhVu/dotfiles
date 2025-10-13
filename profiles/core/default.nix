{ config, pkgs, lib, disko, enableSsh, ... }:
{
  imports = [
    ../common.nix
  ];

  environment.systemPackages = with pkgs; [
    mosh
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      AllowGroups = [ "ssh-user" ];
      Protocol = 2;
      KexAlgorithms = [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-512"
        "hmac-sha2-256"
      ];
      PubkeyAuthentication = true;
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
    };
  };

  systemd.services.cockpit.enable = false;

  system.autoUpgrade.enable = true;

  users.users.quocanh = {
    isNormalUser = true;
    description = "Quoc-Anh Vu";
    extraGroups = [ "wheel" ] ++ lib.optionals enableSsh [ "ssh-user" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICctgJYITp0Xe+Vv8JW1TDbjPsm/6a2v8y36x+9U/Ze1 quocanh@bawk"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBg/QyxNs7g4UpiJumdz6A2di4pBkhFljOiYEEnHZbKc quocanh@woof"
    ];
  };

  users.users.root.hashedPassword = "!";

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

  networking.firewall = lib.mkIf enableSsh {
    allowedTCPPorts = [ 22 ];
    allowedUDPPortRanges = [ { from = 60000; to = 61000; } ]; # For mosh
  };
}
