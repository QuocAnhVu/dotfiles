# GNOME settings: the keyboard, and which extensions are enabled with their
# settings. The extensions themselves come from extensions.gnome.org
# (`./setup.sh <role> extensions` installs the enabled ones that are missing;
# GNOME Shell updates them). Only the keys below are managed: changes made
# elsewhere to other keys stay. The theme keys (user-theme name, gtk-theme)
# belong to theme.sh.
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

    # Keyboard. Caps Lock is another Esc, Shift+Caps Lock is Caps Lock; Esc stays
    # Esc (a swap breaks games under Wine/Proton, which expect Esc on Esc).
    # Menu: third-level characters; Right Ctrl: Compose. Layouts are left alone.
    "org/gnome/desktop/input-sources".xkb-options = [
      "caps:escape_shifted_capslock"
      "lv3:menu_switch"
      "compose:rctrl"
    ];

    # Tiling grid (Super+Enter)
    "org/gnome/shell/extensions/gtile" = {
      grid-sizes = "2x2,3x1";
      auto-close = false;
    };
  };
}
