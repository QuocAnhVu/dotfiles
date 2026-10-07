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

    # Mouse: no acceleration and the default speed, so pointer movement maps
    # 1:1 to the mouse's DPI (set on the mouse itself)
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.0;
    };

    # Alt+Tab switches windows, Super+Tab apps (GNOME: both apps); each only
    # within the current workspace
    "org/gnome/desktop/wm/keybindings" = {
      switch-windows = [ "<Alt>Tab" ];
      switch-applications = [ "<Super>Tab" ];
    };
    "org/gnome/shell/window-switcher".current-workspace-only = true;
    "org/gnome/shell/app-switcher".current-workspace-only = true;

    "org/gnome/desktop/interface" = {
      # No animations (Accessibility > Seeing > Animation Effects)
      enable-animations = false;
      # Fonts (installed by setup.sh): Inter, which GNOME's Adwaita Sans is
      # based on; JetBrains Mono like the terminal (there the Nerd Font version)
      font-name = "Inter Variable 11";
      document-font-name = "Inter Variable 11";
      monospace-font-name = "JetBrains Mono 11";
    };

    # Tiling grid (Super+Enter)
    "org/gnome/shell/extensions/gtile" = {
      grid-sizes = "2x2,3x1";
      auto-close = false;
    };
  };
}
