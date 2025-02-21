{ config, options, lib, inputs, namespace, ... }:
  lib.optionalAttrs (builtins.hasAttr "disko" inputs) {
    imports = [ inputs.disko.nixosModules.disko ];

    options.${namespace}.hardware.disk = lib.mkOption {
      type = lib.types.path;
      default = null;
      description = "The device to install NixOS on.";
    };

    config = lib.mkIf (config.${namespace}.hardware.disk != null) {
      disko.devices.disk.main = {
        device = config.${namespace}.hardware.disk;
        type = "disk";
        content.type = "gpt";

        content.partitions."boot" = {
          size = "1M";
          type = "EF02";
        };

        content.partitions."esp" = {
          size = "512M";
          type = "EF00";
          content.type = "filesystem";
          content.format = "vfat";
          content.mountpoint = "/boot";
          content.mountOptions = [ "umask=0077" ];
          content.extraArgs = [ "-nESP" ];
        };

        content.partitions."nixos" = {
          size = "100%";
          content.type = "filesystem";
          content.format = "ext4";
          content.mountpoint = "/";
          content.extraArgs = [ "-LNIXOS" ];
        };
      };
    };
  }