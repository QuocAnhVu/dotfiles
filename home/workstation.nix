# The workstation role: desktop.nix, the dev suite and the desktop apps. What
# only one machine has (its data drive, its backups) is turned on in that
# machine's ~/.config/local.nix (README: Machine-specific files).
{ config, lib, pkgs, ... }:
let
  # The data drive: each machine's /etc/fstab mounts its drive here
  data = "/mnt/data";
in
{
  imports = [ ./desktop.nix ./full.nix ./backup.nix ];

  options.dotfiles.dataDrive = lib.mkEnableOption "documents and media on the data drive at ${data}";

  config = {
    # Projects in ~/ws; Public (GNOME file sharing) and Templates (Files' "New
    # Document" menu) are unused: set to ~, the convention for off.
    xdg.userDirs = {
      enable = true;
      projects = "${config.home.homeDirectory}/ws";
      publicShare = config.home.homeDirectory;
      templates = config.home.homeDirectory;
    } // lib.optionalAttrs config.dotfiles.dataDrive {
      # Documents and media on the data drive; Desktop and Downloads (cleared by
      # hand) stay on the system drive. enabled=False in user-dirs.conf stops
      # GNOME from resetting them to ~ when the drive is missing at login
      # (screenshots then fail to save, though).
      documents = "${data}/Documents";
      pictures = "${data}/Pictures";
      videos = "${data}/Videos";
      music = "${data}/Music";
    };

    # virsh as a user defaults to qemu:///session: use the system VMs, like
    # virt-manager (setup.sh adds the user to the libvirt group)
    home.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

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
      # Bitwig ships with filesystems=host, so its persistent dirs (.BitwigStudio,
      # "Bitwig Studio") were created in ~ instead of ~/.var/app. Without host they
      # live in ~/.var/app/com.bitwig.BitwigStudio; "Bitwig Studio/Projects" there
      # is a link to ~/ws/music. Plugins run in Bitwig's sandbox, so they need their
      # files too (u-he: presets and license in ~/.u-he, which Diva.clap links into).
      overrides."com.bitwig.BitwigStudio".Context.filesystems = [
        "!host"
        "~/ws/music"
        "~/.local/share/clap:ro"
        "~/.local/share/vst3:ro"
        "~/.local/share/vst:ro"
        "~/.u-he"
        "xdg-music" # samples and exports on the data drive
        "xdg-download:ro"
      ];
    };

    # Hidden in Files: Unreal tools' folders in ~ (fixed paths: the trace store,
    # UnrealBuildTool's Library/Logs)
    home.file.".hidden".text = ''
      Library
      UnrealEngine
    '';
  };
}
