#! /usr/bin/zsh
# https://stribika.github.io/2015/01/04/secure-secure-shell.html

ORANGE='\033[0;33m'
CYAN='\033[0;36m'
GREEN_BOLD='\033[1;32m'
NC='\033[0m'
function context() {
    echo "\n${ORANGE}${@:1}${NC}"
}
function message() {
    echo "${ORANGE}${@:1}${NC}"
}
function run() {
    (echo "${CYAN}${@:1}${NC}") >&2
    eval ${@:1}
}
function prompt() {
    echo -n "${GREEN_BOLD}${@:1}${NC}" >&2
    read response
    echo "$response"
}
XDG_CONFIG_HOME="$HOME/.config"
XDG_CACHE_HOME="$HOME/.cache"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"
DOTFILES="$HOME/ws/dotfiles"

context 'Setting up dotfiles directory'
run mkdir -p $HOME/.ssh
run chmod 700 $HOME/.ssh

context 'Allowing SSH access from 🐔BAWK'
response=$(prompt 'Would you like to allow access from 🐔BAWK? (yes/no): ')
case "$response" in
    [Yy]|[Yy][Ee][Ss])
        if [ ! -f $HOME/.ssh/authorized_keys ]; then
            run touch $HOME/.ssh/authorized_keys
            run chmod 644 $HOME/.ssh/authorized_keys
        else
            message 'Authorized keys file detected'
        fi
        while read key; do
            if ! grep -qF "$key" $HOME/.ssh/authorized_keys; then
                run 'echo "$key" >> $HOME/.ssh/authorized_keys'
            else
                message 'Authorized key detected' $key
            fi
        done < $DOTFILES/.ssh/authorized_keys
        ;;
    *)
        message 'Skipping access grant to 🐔BAWK'
        ;;
esac

context 'Hardening host keys'
pushd /etc/ssh
if [ ! -f /etc/ssh/ssh_host_*key* ]; then
    response=$(prompt 'Would you like to remove any existing host SSH keys? (yes/no): ')
    case "$response" in
        [Yy]|[Yy][Ee][Ss])
            run sudo rm ssh_host_*key*
            ;;
        *)
            message 'Skipping removal of host SSH keys'
            ;;
    esac
fi
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    run 'sudo ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N "" < /dev/null'
else
    message 'Skipping ssh_host_ed25519_key generation'
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ] || [ $(sudo ssh-keygen -lf /etc/ssh/ssh_host_rsa_key | awk '{print $1}') -ne 4096 ]; then
    run 'sudo ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key -N "" < /dev/null'
else
    message 'Skipping ssh_host_rsa_key generation'
fi
popd

context 'Hardening client keys'
response=$(prompt 'Would you like to remove any existing client SSH keys? (yes/no): ')
case "$response" in
    [Yy]|[Yy][Ee][Ss])
        run rm $HOME/.ssh/id_ed25519 $HOME/.ssh/id_rsa
        ;;
    *)
        message 'Skipping removal of existing client SSH keys'
        ;;
esac
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

context 'Installing sshd and mosh'
if command -v apt &> /dev/null; then
    run sudo apt update; run sudo apt -y install openssh-server mosh
elif command -v dnf &> /dev/null; then
    run sudo dnf install -y openssh-server mosh
else
    message "Distro's package manager is not supported."
    exit
fi

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

context 'Generating custom moduli... this may take a while'
function cleanup {
    if [ -f moduli-2048.candidates ]; then
        echo ""
        run rm -f moduli-2048.candidates
    fi
}
trap 'cleanup; exit' SIGINT
run ssh-keygen -M generate -O bits=2048 moduli-2048.candidates
run ssh-keygen -M screen -f moduli-2048.candidates moduli-2048
run sudo mv moduli-2048 /etc/ssh/moduli
trap - SIGINT

context 'Starting sshd service'
run sudo systemctl enable sshd
run sudo systemctl start sshd
