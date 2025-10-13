{ pkgs, disko, ... }:
{
  imports = [
    ./common.nix
    ./../../hardware/disko-config.nix
  ];

  environment.systemPackages = with pkgs; [
    mosh
  ];

  services.openssh = lib.mkIf config.enableSsh {
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

  programs.ssh.extraConfig = lib.mkIf config.enableSsh ''
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

  networking.firewall = lib.mkIf config.enableSsh {
    allowedTCPPorts = [ 22 ];
    allowedUDPPortRanges = [ { from = 60000; to = 61000; } ]; # For mosh
  };
}