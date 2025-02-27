{ config, options, lib, namespace, inputs, ... }:
  lib.optionalAttrs (builtins.hasAttr "disko" inputs) {
    imports = [ inputs.disko.nixosModules.disko ];

    options.${namespace}.hardware = {
      disk = lib.mkOption {
        type = lib.types.path;
        default = "/dev/disk/by-diskseq/1";
        description = "The device to install NixOS on.";
      };
    };

    config = {
      # Boot
      boot.supportedFilesystems = lib.mkForce [ "btrfs" ];
      boot.loader.grub.enable = lib.mkDefault true;
      boot.loader.grub.efiSupport = lib.mkDefault true;
      boot.loader.grub.efiInstallAsRemovable = lib.mkDefault true;

      # Disk
      disko.devices.disk."main" = {
        device = config.${namespace}.hardware.disk;
        type = "disk";
        content.type = "gpt";

        content.partitions."boot" = {
          name = "BOOT";
          size = "1M";
          type = "EF02";
        };

        content.partitions."esp" = {
          name = "ESP";
          size = "500M";
          type = "EF00";
          content.type = "filesystem";
          content.format = "vfat";
          content.mountpoint = "/boot";
          content.extraArgs = [ "-n" "ESP" ];
        };

        content.partitions."root" = {
          name = "NIXOS";
          size = "100%";
          content.type = "lvm_pv";
          content.vg = "nixos";
        };
      };
      disko.devices.lvm_vg."nixos" = {
        type = "lvm_vg";
        lvs."root" = {
          size = "100%FREE";
          content.type = "filesystem";
          content.format = "ext4";
          content.mountpoint = "/";
          content.mountOptions = [ "defaults" ];
          content.extraArgs = [ "-L" "NIXOS" ];
        };
      };
    };
  }