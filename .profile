# Detect the current desktop environment
DESKTOP_SESSION=$(env | grep DESKTOP_SESSION= | cut -d '=' -f 2)

# Swap Caps Lock and Escape keys for each desktop environment
if [ "$DESKTOP_SESSION" == "gnome" ]; then
  gsettings set org.gnome.desktop.input-sources xkb-options "['caps:swapescape']"
elif [ "$DESKTOP_SESSION" == "kde-plasma" ]; then
  kwriteconfig5 --file ~/.config/kxkbrc --group "Layout" --key "CapsLock" --type "string" "Escape"
elif [ "$DESKTOP_SESSION" == "xfce" ]; then
  setxkbmap -option "caps:swapescape"
elif [ "$DESKTOP_SESSION" == "cinnamon" ]; then
  gsettings set org.cinnamon.desktop.input-sources xkb-options "['caps:swapescape']"
elif [ "$DESKTOP_SESSION" == "mate" ]; then
  setxkbmap -option "caps:swapescape"
elif [ "$DESKTOP_SESSION" == "unity" ]; then
  dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:swapescape']"
elif [ "$DESKTOP_SESSION" == "lxde" ]; then
  setxkbmap -option "caps:swapescape"
fi

