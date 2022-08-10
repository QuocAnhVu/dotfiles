#! /usr/bin/zsh
# https://stribika.github.io/2015/01/04/secure-secure-shell.html

# Run this first
DOTFILES=$HOME/.config/dotfiles
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh

# Install sshd
if command -v apt &> /dev/null; then
    sudo apt update; sudo apt -y install openssh-server mosh
elif command -v dnf &> /dev/null; then
    sudo dnf install -y openssh-server mosh
else
    echo "Distro's package manager is not supported."
    exit
fi

# Allow access from BAWK
cat $DOTFILES/.ssh/authorized_keys >> $HOME/.ssh/authorized_keys
chmod 644 $HOME/.ssh/authorized_keys

# SSH access is restricted to only the ssh-user group
sudo groupadd ssh-user
sudo usermod -a -G ssh-user $USER

# Configure ssh with hardened config
sudo mv /etc/ssh/ssh_config /etc/ssh/ssh_config.orig
sudo cp $DOTFILES/.ssh/ssh_config.default /etc/ssh/ssh_config

# Configure sshd with hardened config
# TODO: Use tor hidden services
sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
sudo cp $DOTFILES/.ssh/sshd_config.default /etc/ssh/sshd_config

# Remove weak prime numbers/generators
# Unnecessary in at least Fedora 35+
awk '$5 > 2000' /etc/ssh/moduli > "${HOME}/moduli"
wc -l "${HOME}/moduli" # make sure there is something left
sudo mv "${HOME}/moduli" /etc/ssh/moduli
rm $HOME/moduli

# Harden host keys
pushd /etc/ssh
sudo rm ssh_host_*key*
sudo ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N "" < /dev/null
sudo ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key -N "" < /dev/null
popd

# Generate client keys
ssh-keygen -t ed25519 -o -a 100
ssh-keygen -t rsa -b 4096 -o -a 100

# Start sshd
sudo systemctl enable sshd
sudo systemctl start sshd