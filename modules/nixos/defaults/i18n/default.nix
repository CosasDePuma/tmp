{ config, lib, ... }: {
  # Timezone
  config.time.timeZone = lib.mkDefault "Europe/Madrid";
}