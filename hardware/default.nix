# This is a placeholder for your hardware-specific configuration.
# You will need to replace this with a file generated for your specific hardware.
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}