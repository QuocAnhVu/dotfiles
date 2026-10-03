# The workstation (this desktop): desktop.nix, the dev suite and the desktop apps.
{ config, lib, ... }:
let
  # The data drive: each machine's /etc/fstab mounts its drive here
  data = "/mnt/data";
in
{
  imports = [ ./desktop.nix ./full.nix ./gnome.nix ];

  # Documents and media on the data drive; Desktop and Downloads (cleared by
  # hand) stay on the system drive. Public (GNOME file sharing) and Templates
  # (Files' "New Document" menu) are unused: set to ~, the convention for off.
  # enabled=False in user-dirs.conf stops GNOME from resetting them to ~ when
  # the drive is missing at login (screenshots then fail to save, though).
  xdg.userDirs = {
    enable = true;
    documents = "${data}/Documents";
    pictures = "${data}/Pictures";
    videos = "${data}/Videos";
    music = "${data}/Music";
    projects = "${config.home.homeDirectory}/ws";
    publicShare = config.home.homeDirectory;
    templates = config.home.homeDirectory;
  };

  # ws stays on the system drive (builds write a lot; the drive's connection is
  # flaky): back it up to the data drive hourly, when it's connected
  systemd.user.services.ws-backup = {
    Unit.Description = "Back up ~/ws to ${data}/ws";
    Service = {
      Type = "oneshot";
      ExecStart = "${config.dotfiles.path}/bin/ws-backup";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
  systemd.user.timers.ws-backup = {
    Unit.Description = "Back up ~/ws hourly";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true; # catch up after the machine was off
      RandomizedDelaySec = "5m";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # nix-flatpak runs Nix's flatpak, which writes its NixOS path
  # (/run/current-system/sw/bin/flatpak) into exported D-Bus service files, so
  # D-Bus-activated apps (Flatseal) didn't open from GNOME. Use the system's.
  nixpkgs.overlays = [
    (final: prev: {
      flatpak = final.writeShellScriptBin "flatpak" ''exec /usr/bin/flatpak "$@"'';
    })
  ];

  # Flatpak installs run in the background: nix-flatpak's service is oneshot,
  # so activation waited until every app was downloaded (minutes on a new
  # machine) and failed
  systemd.user.services.flatpak-managed-install.Service.Type = lib.mkForce "exec";

  # Desktop apps from Flathub, in the user installation (~/.local/share/flatpak).
  # Installed and updated by a systemd user service after `home-manager switch`;
  # apps not listed here are removed. App data lives in ~/.var/app either way.
  # Apps that need deeper system access stay system packages (see README).
  services.flatpak = {
    enable = true;
    remotes = [{ name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }];
    uninstallUnmanaged = true;
    update.auto.enable = true; # weekly
    packages = [
      # Audio and video
      "com.bitwig.BitwigStudio"
      "com.github.wwmm.easyeffects"
      "com.obsproject.Studio"
      "io.mpv.Mpv"
      "org.audacityteam.Audacity"
      "org.pipewire.Helvum"
      "org.videolan.VLC"
      # Graphics, 3D, CAD
      "org.blender.Blender"
      "org.freecad.FreeCAD"
      "org.gimp.GIMP"
      "org.kde.krita"
      "org.kde.kruler"
      # Games
      "com.valvesoftware.Steam"
      "net.davidotek.pupgui2" # ProtonUp-Qt
      # Internet and communication
      "com.discordapp.Discord"
      "org.chromium.Chromium"
      # Other
      "com.google.EarthPro"
      "com.github.tchx84.Flatseal"
      "com.mattjakeman.ExtensionManager"
      "org.cryptomator.Cryptomator"
    ];
  };
}
