# GNOME Shell extensions: which are enabled, and their settings. The extensions
# themselves come from extensions.gnome.org (`./setup.sh <role> extensions`
# installs the enabled ones that are missing; GNOME Shell updates them).
# Only the keys below are managed: changes made elsewhere to other keys stay.
# The theme keys (user-theme name, gtk-theme) belong to theme.sh.
{ ... }:
{
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "gTile@vibou"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    # Blur: the overview, panel (dynamic) and Alacritty's background
    "org/gnome/shell/extensions/blur-my-shell/panel".static-blur = false;
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock".blur = false;
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      whitelist = [ "Alacritty" ];
    };

    # Tiling grid (Super+Enter)
    "org/gnome/shell/extensions/gtile" = {
      grid-sizes = "2x2,3x1";
      auto-close = false;
    };
  };
}
