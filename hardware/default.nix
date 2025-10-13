# This is a placeholder for your hardware-specific configuration.
# You will need to replace this with a file generated for your specific hardware.
{
  # Use virtio drivers for virtualized hardware (disk, network, etc.)
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_net" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ]; # No extra modules needed for the guest
  boot.extraModulePackages = [ ];

  # Simplify networking for a typical single-interface VM
  networking.useDHCP = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
