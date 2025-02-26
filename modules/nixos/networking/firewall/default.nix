{ config, lib, ... }: {
  config.networking.firewall.enable = lib.mkDefault true;
  config.networking.firewall.allowedTCPPorts = lib.mkDefault [ ];
  config.networking.firewall.allowedUDPPorts = lib.mkDefault [ ];
}