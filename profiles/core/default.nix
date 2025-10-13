{ config, pkgs, lib, disko, enableSsh, ... }:
{
  imports = [
    ../common.nix
    ./../../hardware/disko-config.nix
  ];

  environment.systemPackages = with pkgs; [
    mosh
  ];

  services.openssh = lib.mkIf enableSsh {
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
      MACs = [
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

  programs.ssh.extraConfig = lib.mkIf enableSsh ''
    PasswordAuthentication yes
    ChallengeResponseAuthentication no
    PubkeyAuthentication yes
    HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa
    KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
    UseRoaming no
  '';

  systemd.services.cockpit.enable = false;

  system.autoUpgrade.enable = true;

  users.users.quocanh = {
    isNormalUser = true;
    description = "Quoc-Anh Vu";
    extraGroups = [ "wheel" ] ++ lib.mkIf enableSsh [ "ssh-user" ];
    shell = pkgs.zsh;
  };

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
