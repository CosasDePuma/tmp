{ config, lib, ... }: {
  # System packages
  config.system.stateVersion = lib.mkForce "25.05";
}