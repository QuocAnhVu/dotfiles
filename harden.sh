#! /usr/bin/zsh
# Set up SSH: client key, and (only on machines that should accept SSH) a
# hardened sshd. Safe to rerun.
source $(dirname $0)/_lib.sh
setopt err_exit

DOTFILES=$(cd $(dirname $0) && pwd)
DROPIN=/etc/ssh/sshd_config.d/00-hardening.conf

function confirm() {
    prompt "$1 (yes/no): "
    read response
    [[ ${response:l} == (y|yes) ]]
}

context 'Setting up ~/.ssh'
run mkdir -p $HOME/.ssh
run chmod 700 $HOME/.ssh

context 'Client key'
if [[ ! -f $HOME/.ssh/id_ed25519 ]]; then
    run ssh-keygen -t ed25519 -a 100 -f $HOME/.ssh/id_ed25519
else
    message 'id_ed25519 exists'
fi

context 'SSH server'
if ! confirm 'Should this machine accept SSH connections?'; then
    message 'Leaving sshd off. (Rerun to change this.)'
    if systemctl is-enabled --quiet sshd 2> /dev/null; then
        message "Note: sshd is currently enabled. Disable it with: sudo systemctl disable --now sshd"
    fi
    exit 0
fi

if confirm 'Allow @quocanh (keys in .ssh/authorized_keys) to log in?'; then
    run touch $HOME/.ssh/authorized_keys
    run chmod 600 $HOME/.ssh/authorized_keys
    while read key; do
        [[ -n $key ]] || continue
        if ! grep -qxF $key $HOME/.ssh/authorized_keys; then
            run_noeval "append key: ${key##* }"
            print -r -- $key >> $HOME/.ssh/authorized_keys
        fi
    done < $DOTFILES/.ssh/authorized_keys
fi

if command -v apt > /dev/null; then
    run sudo apt-get install -y openssh-server mosh
elif command -v dnf > /dev/null; then
    run sudo dnf install -y openssh-server mosh
fi

getent group ssh-user > /dev/null || run sudo groupadd ssh-user
id -nG $USER | grep -qw ssh-user || run sudo usermod -a -G ssh-user $USER

# A drop-in, not a replacement sshd_config: the distro's defaults (sftp
# subsystem, PAM, crypto policy) stay intact. sshd uses the first value it reads
# for each option, and drop-ins are read in name order, so 00- takes precedence
# over distro and cloud-init drop-ins (e.g. 50-cloud-init.conf enabling
# passwords). Algorithms are left at OpenSSH's defaults, which include
# post-quantum key exchange.
context "Writing $DROPIN"
run sudo mkdir -p /etc/ssh/sshd_config.d
run_noeval "sudo tee $DROPIN"
sudo tee $DROPIN > /dev/null << 'END'
# Managed by dotfiles/harden.sh
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
AuthenticationMethods publickey
AllowGroups ssh-user
END
if ! sudo grep -qE '^\s*Include\s+/etc/ssh/sshd_config.d/\*\.conf' /etc/ssh/sshd_config; then
    message "Warning: /etc/ssh/sshd_config doesn't include sshd_config.d/*.conf, so $DROPIN has no effect."
fi
run sudo sshd -t # validate before (re)starting

# Debian names the unit ssh, Fedora sshd
unit=sshd
systemctl list-unit-files ssh.service > /dev/null 2>&1 && unit=ssh
run sudo systemctl enable --now $unit
run sudo systemctl reload $unit

if command -v firewall-cmd > /dev/null; then
    context 'Opening ssh and mosh in firewalld'
    run sudo firewall-cmd --permanent --add-service=ssh --add-service=mosh
    run sudo firewall-cmd --reload
fi

message "Log in again for the ssh-user group to apply to $USER."
