# Backups to the HDD with restic (encrypted, deduplicated snapshots), off
# unless this machine's ~/.config/local.nix turns them on (README: Data drive):
# ws, which stays on the system drive (builds write a lot), every 15 minutes;
# the data drive daily.
{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.backup;
  data = "/mnt/data";
  service = description: script: {
    Unit.Description = description;
    Service = {
      Type = "oneshot";
      ExecStart = "${config.dotfiles.path}/bin/${script}";
      Environment = "PATH=${lib.makeBinPath [ pkgs.restic ]}:/usr/bin:/bin";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
in
{
  options.dotfiles.backup = {
    ws.enable = lib.mkEnableOption "backing up ~/ws to the HDD every 15 minutes (bin/ws-backup)";
    data.enable = lib.mkEnableOption "backing up the data drive to the HDD daily (bin/data-backup)";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.ws.enable || cfg.data.enable) {
      home.packages = [ pkgs.restic ];
    })
    (lib.mkIf cfg.ws.enable {
      systemd.user.services.ws-backup = service "Back up ~/ws to the HDD" "ws-backup";
      systemd.user.timers.ws-backup = {
        Unit.Description = "Back up ~/ws every 15 minutes";
        Timer = {
          OnCalendar = "*:0/15";
          Persistent = true; # catch up after the machine was off
          RandomizedDelaySec = "1m";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    })
    (lib.mkIf cfg.data.enable {
      systemd.user.services.data-backup = service "Back up ${data} to the HDD" "data-backup";
      systemd.user.timers.data-backup = {
        Unit.Description = "Back up ${data} to the HDD daily";
        Timer = {
          OnCalendar = "daily";
          Persistent = true; # catch up after the machine was off
          RandomizedDelaySec = "30m";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    })
  ];
}
