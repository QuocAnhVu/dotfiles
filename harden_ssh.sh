#! /usr/bin/zsh
# https://stribika.github.io/2015/01/04/secure-secure-shell.html

ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
function context() {
    echo "\n${ORANGE}${@:1}${NC}"
}
function message() {
    echo "${ORANGE}${@:1}${NC}"
}
function run() {
    echo "${CYAN}${@:1}${NC}"
    eval ${@:1}
}
XDG_CONFIG_HOME="$HOME/.config"
XDG_CACHE_HOME="$HOME/.cache"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"

context 'Setting up dotfiles directory'
run mkdir -p $HOME/.ssh
run chmod 700 $HOME/.ssh

context 'Installing sshd and mosh'
if command -v apt &> /dev/null; then
    run sudo apt update; run sudo apt -y install openssh-server mosh
elif command -v dnf &> /dev/null; then
    run sudo dnf install -y openssh-server mosh
else
    message "Distro's package manager is not supported."
    exit
fi

context 'Allowing access from BAWK'
if [ ! -f $HOME/.ssh/authorized_keys ]; then
    run touch $HOME/.ssh/authorized_keys
    run chmod 644 $HOME/.ssh/authorized_keys
fi
while read key; do
    if ! grep -qF "$key" $HOME/.ssh/authorized_keys; then
        run echo "$key" >> $HOME/.ssh/authorized_keys
    fi
done < $DOTFILES/.ssh/authorized_keys
context 'Restricting SSH access to ssh-user group'
run sudo groupadd ssh-user
run sudo usermod -a -G ssh-user $USER

context 'Configuring ssh with hardened config'
if [ -f /etc/ssh/ssh_config ]; then
    run sudo mv /etc/ssh/ssh_config /etc/ssh/ssh_config.orig
fi
run sudo cp $DOTFILES/.ssh/ssh_config.default /etc/ssh/ssh_config

context 'Configuring sshd with hardened config'
if [ -f /etc/ssh/sshd_config ]; then
    run sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
fi
run sudo cp $DOTFILES/.ssh/sshd_config.default /etc/ssh/sshd_config

context 'Removing weak prime numbers/generators'
run awk '$5 > 2000' /etc/ssh/moduli > "${HOME}/moduli"
run wc -l "${HOME}/moduli" # make sure there is something left
run sudo mv "${HOME}/moduli" /etc/ssh/moduli
run rm $HOME/moduli

context 'Hardening host keys'
pushd /etc/ssh
run sudo rm ssh_host_*key*
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    run sudo ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N "" < /dev/null
else
    message 'Skipping ssh_host_ed25519_key generation'
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ] || [ $(ssh-keygen -lf /etc/ssh/ssh_host_rsa_key | awk '{print $1}') -ne 4096 ]; then
    run sudo ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key -N "" < /dev/null
else
    message 'Skipping ssh_host_rsa_key generation'
fi
popd

context 'Generating client keys'
if [ ! -f $HOME/.ssh/id_ed25519 ]; then
    run ssh-keygen -t ed25519 -o -a 100 -f $HOME/.ssh/id_ed25519
else
    message 'Skipping id_ed25519 key generation'
fi
if [ ! -f $HOME/.ssh/id_rsa ] || [ $(ssh-keygen -lf $HOME/.ssh/id_rsa | awk '{print $1}') -ne 4096 ]; then
    run ssh-keygen -t rsa -b 4096 -o -a 100 -f $HOME/.ssh/id_rsa
else
    message 'Skipping id_rsa key generation'
fi

context 'Starting sshd service'
run sudo systemctl enable sshd
run sudo systemctl start sshd
