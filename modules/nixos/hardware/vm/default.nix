{ config, options, lib, namespace, ... }: {
  options.${namespace}.hardware.vm = mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable support for running NixOS as a virtual machine.";
  };

  config = lib.mkIf config.${namespace}.hardware.vm {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.initrd.availableKernelModules = [
      "9p"
      "9pnet_virtio"
      "virtio_blk"
      "virtio_net"
      "virtio_mmio"
      "virtio_pci"
      "virtio_scsi"
    ];
    boot.initrd.kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_gpu"
      "virtio_rng"
    ];
  };
}