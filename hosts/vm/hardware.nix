{
  # Use virtio drivers for virtualized hardware (disk, network, etc.)
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_net" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ]; # No extra modules needed for the guest
  boot.extraModulePackages = [ ];

  # Simplify networking for a typical single-interface VM

  nixpkgs.hostPlatform = "x86_64-linux";
}
