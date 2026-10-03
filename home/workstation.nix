# The workstation (this desktop): desktop.nix plus the desktop apps.
{ ... }:
{
  imports = [ ./desktop.nix ./gnome.nix ];

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
