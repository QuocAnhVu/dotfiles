# Check the display server type
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # If using Wayland, set the "caps:swapescape" option using gsettings
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:swapescape']"
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    # If using X11, set the "caps:swapescape" option using setxkbmap
    setxkbmap -option caps:swapescape
fi