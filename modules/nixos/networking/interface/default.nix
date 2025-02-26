{ config, options, lib, namespace, ... }: {
  options.${namespace}.networking = {
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "The hostname of the machine.";
    };

    ipv4 = lib.mkOption {
      type = lib.types.str;
      default = "dhcp";
      description = "The IPv4 address of the machine. Can be set to 'dhcp' or a static IP address.";
    };
  };

  config = {
    # Hostname
    networking.hostName = lib.mkDefault options.${namespace}.networking.hostname;

    # Interfaces
    networking.usePredictableInterfaceNames = lib.mkDefault false;
    #networking.networkmanager.enable = lib.mkDefault options.${namespace}.networking.ipv4 == "dhcp";
    #networking.interfaces."eth0".ipv4.addresses = lib.mkIf (options.${namespace}.networking.ipv4 != "dhcp") {
    #  address = options.${namespace}.networking.ipv4;
    #  prefixLength = 24;
    #};
    #networking.defaultGateway = lib.mkIf (options.${namespace}.networking.ipv4 != "dhcp") {
    #  interface = "eth0";
    #  address = lib.concatStringsSep "." ((lib.take 3 (lib.splitString "." options.${namespace}.networking.ipv4)) ++ [ "1" ]);
    #};

    # DNS
    networking.nameservers = lib.mkDefault [ "1.1.1.1" "8.8.8.8" ];
  };
}