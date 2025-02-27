{ config, options, lib, namespace, ... }: {
  options.${namespace}.hardware.isVM = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether the hardware is a virtual machine or not.";
  };

  config = lib.mkIf config.${namespace}.hardware.isVM {
    # Firmware
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # Modules
    boot.initrd.availableKernelModules = lib.mkDefault [
      "9p"
      "9pnet_virtio"
      "ata_piix"
      "sd_mod"
      "sr_mod"
      "uhci_hcd"
      "virtio_blk"
      "virtio_net"
      "virtio_mmio"
      "virtio_pci"
      "virtio_scsi"
      "vmw_pvscsi"
      "xen_blkfront"
    ];
    boot.initrd.kernelModules = lib.mkDefault [
      "virtio_balloon"
      "virtio_console"
      "virtio_gpu"
      "virtio_rng"
    ];
    boot.kernelModules = lib.mkDefault [ "kvm-amd" "kvm-intel" ];

    # Services
    services.qemuGuest.enable = lib.mkDefault true;
  };
}