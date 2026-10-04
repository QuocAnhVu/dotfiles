#! /usr/bin/zsh
# Switch the desktop theme: alacritty, helix, zellij, GTK and GNOME Shell, and
# the icon theme's colour. Installs the GTK/GNOME Shell theme (into
# $XDG_DATA_HOME/themes), the icons and the cursor (into $XDG_DATA_HOME/icons,
# where Flatpak apps see them too) first if they are missing, or always with
# --update. --current reapplies the theme the configs select (setup.sh uses it
# on new machines).
source $(dirname $0)/_lib.sh
setopt err_exit

SCRIPT=$0
DOTFILES=$(cd $(dirname $0) && pwd)
THEMES_DIR=$XDG_DATA_HOME/themes
ICONS_DIR=$XDG_DATA_HOME/icons
SRC_DIR=$HOME/ws/3p
USER_THEME=user-theme@gnome-shell-extensions.gcampax.github.com

# Per-theme settings. To add a theme, add a column here and its option lines in
# the alacritty/helix/zellij configs.
typeset -A ALACRITTY HELIX ZELLIJ NVIM DELTA GTK REPO TWEAK ICONS
ALACRITTY=(nord nord               gruvbox gruvbox_dark                       everforest everforest_dark)
HELIX=(    nord nord               gruvbox gruvbox_dark_soft                  everforest everforest_dark)
ZELLIJ=(   nord nord               gruvbox gruvbox-dark                       everforest everforest-dark)
NVIM=(     nord nord               gruvbox gruvbox                            everforest everforest)
DELTA=(    nord Nord               gruvbox gruvbox-dark                       everforest ansi)
GTK=(      nord Nordic             gruvbox Gruvbox-Dark-Soft                  everforest Everforest-Dark-Medium)
REPO=(     nord EliverLara/Nordic  gruvbox Fausto-Korpsvart/Gruvbox-GTK-Theme everforest Fausto-Korpsvart/Everforest-GTK-Theme)
TWEAK=(                            gruvbox soft                               everforest medium)
# Tela-circle folder colour: one of its variants, or a hex code. Dark tones from
# the background end of the palette look best; accents are too bright.
ICONS=(    nord nord               gruvbox 504945                             everforest 56635F)

# Icons and cursor: the same for every theme
ICONS_REPO=vinceliuice/Tela-circle-icon-theme
CURSOR=Bibata-Modern-Ice
CURSOR_URL=https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/$CURSOR.tar.xz

function usage() {
    local themes=(${(ko)GTK})
    echo "Usage: $SCRIPT [-u|--update] <${(j:|:)themes}|--current>"
    echo "  -u, --update  Pull and reinstall the GTK/GNOME Shell theme, icons and cursor"
    echo "  --current     The theme the configs select now (the alacritty import)"
    exit 1
}

# Uncomment the option line equal to `want` and comment out the other lines
# matching `pattern` (an awk regex for the bare, uncommented line).
function select_line() {
    local file=$1 comment="$2 " pattern=$3 want=$4
    grep --quiet --fixed-strings --line-regexp -e "$want" -e "$comment$want" $file \
        || { message "No '$want' option line in $file"; exit 1 }
    # Pass via ENVIRON: awk -v would treat the regex's backslashes as escapes
    local out=$(c=$comment re=$pattern want=$want awk '{
        c = ENVIRON["c"]; bare = index($0, c) == 1 ? substr($0, length(c) + 1) : $0
        if (bare ~ ENVIRON["re"]) print (bare == ENVIRON["want"] ? bare : c bare); else print
    }' $file)
    # Write in place (not mv) so file watchers like alacritty's live reload see it
    print -r -- "$out" > $file
    run_noeval "$file: $want"
}

# Install sassc/git, gtk-update-icon-cache and the User Themes extension if
# missing (Debian or Fedora).
function install_prerequisites() {
    local pkgs=()
    (( $+commands[sassc] )) || pkgs+=(sassc)
    (( $+commands[git] )) || pkgs+=(git)
    (( $+commands[gtk-update-icon-cache] )) || pkgs+=(gtk-update-icon-cache)
    if ! gnome-extensions info $USER_THEME &> /dev/null; then
        if (( $+commands[apt-get] )); then
            pkgs+=(gnome-shell-extensions) # includes User Themes on Debian
        else
            pkgs+=(gnome-shell-extension-user-theme)
        fi
    fi
    if (( $#pkgs )); then
        if (( $+commands[apt-get] )); then
            run sudo apt-get install -y $pkgs
        else
            run sudo dnf install -y $pkgs
        fi
    fi
    if ! gnome-extensions enable $USER_THEME 2> /dev/null; then
        message "GNOME Shell doesn't see the User Themes extension yet: log out and back in, then rerun."
    fi
}

function clone_or_pull() {
    local dir=$SRC_DIR/${1:t}
    if [[ -d $dir ]]; then
        run git -C $dir pull --ff-only
    else
        run mkdir -p $SRC_DIR
        run git clone --depth 1 https://github.com/$1.git $dir
    fi
}

function install_gtk_theme() {
    local t=$1 dir=$SRC_DIR/${REPO[$1]:t} dest=$THEMES_DIR/${GTK[$1]}
    install_prerequisites
    clone_or_pull ${REPO[$t]}
    run mkdir -p $THEMES_DIR
    if [[ -n ${TWEAK[$t]} ]]; then
        # Fausto-Korpsvart themes: build with the repo's install script.
        # Not using its -l: it deletes ~/.config/gtk-4.0 files; we link below.
        run $dir/themes/install.sh -d $THEMES_DIR -c dark --tweaks ${TWEAK[$t]} macos
        run rm -rf $dest-hdpi $dest-xhdpi # XFCE only
    else
        # Nordic: prebuilt CSS is committed, so copy just the theme folders
        run rm -rf $dest
        run mkdir -p $dest
        run cp -a $dir/{assets,cinnamon,gnome-shell,gtk-2.0,gtk-3.0,gtk-4.0,metacity-1,xfwm4,index.theme,LICENSE,README.md} $dest/
        run find $dest -name "'*.scss'" -delete
        run find $dest -type d -empty -delete
    fi
}

# Tela-circle in one colour; its installer adds -light and -dark versions
function install_icons() {
    install_prerequisites
    clone_or_pull $ICONS_REPO
    run mkdir -p $ICONS_DIR
    run $SRC_DIR/${ICONS_REPO:t}/install.sh -d $ICONS_DIR $1
}

# Prebuilt from the release. default/ makes it the cursor for X11 apps
# (XWayland: games, Steam) that don't read GNOME's setting.
function install_cursor() {
    run mkdir -p $ICONS_DIR/default
    run rm -rf $ICONS_DIR/$CURSOR
    run_noeval "curl -fsSL $CURSOR_URL | tar -xJ -C $ICONS_DIR"
    curl -fsSL $CURSOR_URL | tar -xJ -C $ICONS_DIR
    print "[Icon Theme]\nInherits=$CURSOR" > $ICONS_DIR/default/index.theme
    run_noeval "$ICONS_DIR/default/index.theme: Inherits=$CURSOR"
}

# libadwaita apps only read ~/.config/gtk-4.0. Import the theme's CSS instead of
# symlinking it, so relative asset URLs (e.g. Nordic's ../assets) resolve
# against the theme directory.
function link_gtk4() {
    local src=$THEMES_DIR/$1/gtk-4.0 cfg=$XDG_CONFIG_HOME/gtk-4.0
    run mkdir -p $cfg
    run rm -f $cfg/{assets,gtk.css,gtk-dark.css}
    for f in gtk.css gtk-dark.css; do
        print "/* Managed by dotfiles/theme.sh */\n@import url(\"file://$src/$f\");" > $cfg/$f
        run_noeval "$cfg/$f -> $src/$f"
    done
}

update=
case $1 in
    -u | --update) update=true; shift ;;
esac
theme=$1
if [[ $theme == --current ]]; then
    theme=
    for t in ${(k)ALACRITTY}; do
        if grep -qxF "import = [\"themes/${ALACRITTY[$t]}.toml\"]" $DOTFILES/.config/alacritty/alacritty.toml; then
            theme=$t
        fi
    done
fi
[[ -n $theme && -n ${GTK[$theme]} ]] || usage

context "Terminal and editor: $theme"
select_line $DOTFILES/.config/alacritty/alacritty.toml '#' '^import = \["themes/[^"]+\.toml"\]$' \
    "import = [\"themes/${ALACRITTY[$theme]}.toml\"]"
select_line $DOTFILES/.config/helix/config.toml '#' '^theme = "[^"]+"$' "theme = \"${HELIX[$theme]}\""
select_line $DOTFILES/.config/zellij/config.kdl '//' '^theme "[^"]+"$' "theme \"${ZELLIJ[$theme]}\""
select_line $DOTFILES/.config/nvim/init.lua '--' '^pcall\(vim\.cmd\.colorscheme, "[^"]+"\)$' \
    "pcall(vim.cmd.colorscheme, \"${NVIM[$theme]}\")"
select_line $DOTFILES/.config/git/config '#' '^syntax-theme = .+$' "syntax-theme = ${DELTA[$theme]}" # delta (no everforest theme: ansi uses terminal colours)

if [[ -n $update || ! -d $THEMES_DIR/${GTK[$theme]} ]]; then
    context "Installing GTK/GNOME Shell theme ${GTK[$theme]}"
    install_gtk_theme $theme
fi

icons=Tela-circle-${ICONS[$theme]}-dark
if [[ -n $update || ! -d $ICONS_DIR/$icons ]]; then
    context "Installing icon theme $icons"
    install_icons ${ICONS[$theme]}
fi
if [[ -n $update || ! -d $ICONS_DIR/$CURSOR ]]; then
    context "Installing cursor $CURSOR"
    install_cursor
fi

context "GTK and GNOME Shell: ${GTK[$theme]}, icons $icons, cursor $CURSOR"
run gsettings set org.gnome.desktop.interface color-scheme prefer-dark
run gsettings set org.gnome.desktop.interface gtk-theme ${GTK[$theme]}
run gsettings set org.gnome.desktop.interface icon-theme $icons
run gsettings set org.gnome.desktop.interface cursor-theme $CURSOR
run_noeval "dconf write /org/gnome/shell/extensions/user-theme/name \"'${GTK[$theme]}'\""
dconf write /org/gnome/shell/extensions/user-theme/name "'${GTK[$theme]}'"
link_gtk4 ${GTK[$theme]}

context "Done"
message "Alacritty has reloaded. Still to reload:"
message "  helix:  :config-reload"
message "  zellij: new session"
message "  neovim: restart"
message "  libadwaita apps: reopen them"
