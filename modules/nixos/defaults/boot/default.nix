{ config, lib, ... }: {
  # Boot
  config.boot.loader.grub.enable = lib.mkDefault true;
  config.boot.loader.grub.devices = lib.mkDefault [ "nodev" ];
  config.boot.loader.grub.efiSupport = lib.mkDefault true;
  config.boot.loader.grub.efiInstallAsRemovable = lib.mkDefault true;

  # Kernel modules
  config.boot.initrd.availableKernelModules = []; #[ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  
  # Filesystems
  config.fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };
  config.fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
}