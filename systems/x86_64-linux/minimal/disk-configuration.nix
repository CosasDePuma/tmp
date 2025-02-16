{ lib, inputs, device ? throw "Set this to your main disk device (e.g. /dev/sda)" }:
  lib.optionalAttrs (builtins.hasAttr "disko" inputs) {
    imports = [ inputs.disko.nixosModules.disko ];
    
    disko.devices.disk.main = {
      inherit device;
      type = "disk";
      content.type = "gpt";
      
      content.partitions.boot = {
        name = "BOOT";
        size = "1M";
        type = "EF02";
      };

      content.partitions.esp = {
        name = "ESP";
        size = "500M";
        type = "EF00";
        content.type = "filesystem";
        content.format = "vfat";
        content.mountpoint = "/boot";
        content.mountOptions = [ "umask=0077" ];
      };

      content.partitions.root = {
        name = "NIXOS";
        size = "100%";
        content.type = "filesystem";
        content.format = "ext4";
        content.mountpoint = "/";
      };
    };
  }