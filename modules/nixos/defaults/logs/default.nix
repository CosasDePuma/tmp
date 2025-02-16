{ config, lib, ... }: {
  config.services.journald.storage = lib.mkDefault "persistent";
  config.services.journald.extraConfig = lib.mkDefault ''
    MaxRetentionSec="1month"
    RuntimeMaxUse="1G"
    SystemMaxUse="2G"
  '';
}