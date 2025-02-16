{ config, lib, ... }: {
  # DNS
  config.networking.nameservers = lib.mkDefault [ "1.1.1.1" "8.8.8.8" ];

  # Firewall
  config.networking.firewall.enable = lib.mkDefault true;
  config.networking.firewall.allowedTCPPorts = lib.mkDefault [ ];
  config.networking.firewall.allowedUDPPorts = lib.mkDefault [ ];

  # Interfaces
  config.networking.usePredictableInterfaceNames = lib.mkDefault false;
}