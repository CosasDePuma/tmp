{ config, lib, ... }: {
  # System version
  config.system.stateVersion = lib.mkForce "25.05";

  # System autoupgrade
  config.system.autoUpgrade.enable = lib.mkDefault  true;
  config.system.autoUpgrade.allowReboot = lib.mkDefault true;
  config.system.autoUpgrade.persistent = lib.mkDefault true;
  config.system.autoUpgrade.dates = lib.mkDefault "weekly";

  # Package manager garbage collector
  config.nix.gc.automatic = lib.mkDefault  true;
  config.nix.gc.dates = lib.mkDefault "weekly";
  config.nix.gc.options = lib.mkDefault "--delete-older-than 7d";
  config.nix.gc.persistent = lib.mkDefault true;
}