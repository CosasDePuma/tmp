{ config, lib, ... }: {
  # Boot
  config.boot.loader.grub.enable = lib.mkDefault true;
  config.boot.loader.grub.devices = lib.mkDefault [ "nodev" ];
  config.boot.loader.grub.efiSupport = lib.mkDefault true;
  config.boot.loader.grub.efiInstallAsRemovable = lib.mkDefault true;

  # Filesystems
  config.fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };
  config.fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };
}