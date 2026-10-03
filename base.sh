#! /usr/bin/zsh
source $(dirname $0)/_lib.sh

context 'Ensuring XDG directories exist'
run mkdir -p $XDG_CONFIG_HOME
run mkdir -p $XDG_CACHE_HOME
run mkdir -p $XDG_DATA_HOME
run mkdir -p $XDG_STATE_HOME

# Config files are linked by home-manager: see home.sh

context 'Creating prerequisite directories'
run mkdir -p $HOME/ws
run mkdir -p $XDG_STATE_HOME/bash # for bash_history
run mkdir -p $XDG_STATE_HOME/zsh  # for zsh_history
run mkdir -p $XDG_CONFIG_HOME/environment.d # machine-specific variables: 90-local.conf
run "touch $XDG_CONFIG_HOME/secrets.env && chmod 600 $XDG_CONFIG_HOME/secrets.env"

context 'Installing packages (the rest comes from home-manager: ./home.sh)'
if rg --quiet '^ID=fedora' /etc/os-release; then
    run sudo dnf upgrade -y
    run sudo dnf install -y curl git
elif rg --quiet '^ID=debian' /etc/os-release; then
    run sudo apt-get update
    run sudo apt-get upgrade -y
    run sudo apt-get install -y curl git
fi

context 'Enabling automatic updates'
if rg --quiet '^ID=fedora' /etc/os-release; then
    # dnf5: defaults are in /usr/share/dnf5/dnf5-plugins/automatic.conf; override here
    run sudo dnf install -y dnf-automatic
    run_noeval "apply_updates = yes > /etc/dnf/dnf5-plugins/automatic.conf"
    printf '[commands]\napply_updates = yes\n' | sudo tee /etc/dnf/dnf5-plugins/automatic.conf > /dev/null
    run sudo systemctl enable --now dnf5-automatic.timer
elif rg --quiet '^ID=debian' /etc/os-release; then
    run sudo apt-get install -y unattended-upgrades
    run_noeval "enable unattended-upgrades (debconf)"
    echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | sudo debconf-set-selections
    run sudo dpkg-reconfigure -f noninteractive unattended-upgrades
fi
