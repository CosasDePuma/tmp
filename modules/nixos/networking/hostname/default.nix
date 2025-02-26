{ config, options, lib, namespace, ... }: {
  options.${namespace}.networking.hostname = lib.mkOption {
    type = lib.types.string;
    default = "nixos";
    description = "The hostname of the machine.";
  };

  config.networking.hostName = lib.mkDefault options.${namespace}.networking.hostname;
}