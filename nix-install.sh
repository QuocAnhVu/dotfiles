#!/usr/bin/env bash

# This script is a reference for the commands needed to install NixOS on a new machine.
# It is intended to be used by copy-pasting the commands into the terminal of the NixOS installer environment.

# =====================================================================================
# Scenario 1: Install a minimal server with SSH access ('''vm-core''')
# =====================================================================================

# --- 1A. Partition the disk for the server ---
# This uses '''disko''' with the configuration from '''hosts/vm/disko.nix'''.
# IMPORTANT: Replace '/dev/vda' with the correct device name.
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko hosts/vm/disko.nix --arg device '"/dev/vda"'

# --- 1B. Install NixOS for the server ---
# This installs the '''vm-core''' configuration, which has SSH enabled by default.
# Access is granted via the SSH keys configured in '''profiles/core/default.nix'''.
sudo nixos-install --flake .#vm-core


# =====================================================================================
# Scenario 2: Install a full desktop with no SSH access ('''desktop-full''')
# =====================================================================================

# --- 2A. Partition the disk for the desktop ---
# IMPORTANT: You should create a specific disko configuration for your desktop hardware.
# The command below is a placeholder using the VM config and would need to be adapted.
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko hosts/desktop/disko.nix --arg device '"/dev/nvme0n1"'

# --- 2B. Install NixOS for the desktop ---
# This installs the '''desktop-full''' configuration.
#
# NOTE: SSH access is explicitly DISABLED for this profile via the '''enableSsh = false;'''
# argument in your flake.nix.
#
# You MUST configure a user password in your NixOS configuration to be able to log in.
#
# CAVEAT: Your '''desktop-full''' configuration currently uses the '''./hosts/vm''' module.
# You may want to change this to '''./hosts/desktop''' in your flake.nix for a real desktop install.
#
# sudo nixos-install --flake .#desktop-full
