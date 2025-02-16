{ config, lib, ... }: {
  config = lib.mkIf config.services.fail2ban.enable {
    services.fail2ban.maxretry = lib.mkDefault 3;
    services.fail2ban.bantime = lib.mkDefault "30d";
  };
}