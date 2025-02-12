{ config, lib, pkgs, ... }:
  let
    user = "joker";
    domain = "kike.wtf";
  in
{
  imports = [ ./hardware-configuration.nix ];

  # System
  system.stateVersion = "24.11";
  system.copySystemConfiguration = true;
  nixpkgs.config.allowUnfree = true;

  # Boot
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # DNS
  networking.hostName = "arkham";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Network interfaces
  networking.usePredictableInterfaceNames = false;
  networking.interfaces."eth0".ipv4.addresses = [{ address = "192.168.1.2"; prefixLength = 24; }];  
  networking.defaultGateway = { interface = "eth0"; address = "192.168.1.1"; };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 8080 4646 ];
  networking.firewall.allowedUDPPorts = [];

  # Localization
  time.timeZone = "Europe/Madrid";

  # Packages
  environment.systemPackages = with pkgs; [ nano ];

  # Users
  users.groups."users" = {};

  users.users."${user}" = {
    description = "Why so serious?";
    createHome = false;
    password = null;
    isSystemUser = true;
    group = "users";
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos@infra" ];
  };

  # Maintenance: System GC
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";
  nix.gc.persistent = true;

  # Maintenance: System autoupgrade
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.persistent = true;
  system.autoUpgrade.dates = "weekly";

  # Maintenance: Journald
  services.journald.storage = "persistent";
  services.journald.extraConfig = ''
    MaxRetentionSec="1month"
    RuntimeMaxUse="1G"
    SystemMaxUse="2G"
  '';

  # Services: SSH
  services.openssh.enable = true;
  services.openssh.ports = [ 9022 ];
  services.openssh.openFirewall = true;
  services.openssh.authorizedKeysInHomedir = false;
  services.openssh.settings.AllowUsers = [ "${user}" ];
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.X11Forwarding = false;
  services.openssh.banner = ''
    ==============================================================
    |                   AUTHORIZED ACCESS ONLY                   |
    ==============================================================
    |                                                            |
    |  WARNING: All connections are monitored and recorded       |
    |  Disconnect IMMEDIATELY if you are not an authorized user! |
    |                                                            |
    |  * All actions are logged and monitored                    |
    |  * Unauthorized access will be prosecuted                  |
    |                                                            |
    ==============================================================
  '';
  # -- ssh agent: eval "$(ssh-agent -s)" && ssh-add ~/.ssh/nixos
  security.pam.sshAgentAuth.enable = true;
  security.pam.sshAgentAuth.authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
  security.pam.services.sudo.sshAgentAuth = true;

  # Services: Fail2Ban
  services.fail2ban.enable = true;
  services.fail2ban.maxretry = 3;
  services.fail2ban.bantime = "30d";

  # Services: Traefik
  services.traefik.enable = true;
  services.traefik.staticConfigOptions = {
    accesslog.format = "common";
    accesslog.filepath = "/var/lib/traefik/access.log";
    api.dashboard = true;
    api.insecure = true;
    entrypoints.http.address = ":80/tcp";
    entrypoints.https.address = ":443/tcp";
    global.checkNewVersion = true;
    global.sendAnonymousUsage = false;
    log.level = "DEBUG";
  };
  services.traefik.dynamicConfigOptions = {
    http.middlewares.all.chain.middlewares = [ "compress@file" "jokes@file" ];
    http.middlewares.compression.compress.minResponseBodyBytes = 1024;
    http.middlewares.compression.compress.excludedContentTypes = [ "text/event-stream" ];
    http.middlewares.https-only.chain.middlewares = [ "https-redirect@file" "hsts@file" ];
    http.middlewares.https-redirect.redirectScheme.permanent = true;
    http.middlewares.https-redirect.redirectScheme.port = "443";
    http.middlewares.https-redirect.redirectScheme.scheme = "https";
    http.middlewares.hsts.headers.forceSTSHeader = true;
    http.middlewares.hsts.headers.stsPreload = true;
    http.middlewares.hsts.headers.stsSeconds = 31536000;
    http.middlewares.hsts.headers.stsIncludeSubdomains = true;
    http.middlewares.jokes.headers.customResponseHeaders.Server = "'; DROP TABLE users; -- /*";
    http.middlewares.jokes.headers.customResponseHeaders.X-PoweredBy = "Pumas, unicorns and rainbows";
    http.middlewares.jokes.headers.customResponseHeaders.X-NaNaNaNaNaNaNaNa = "Batman!";
    http.middlewares.jokes.headers.customResponseHeaders.X-Clacks-Overhead = "GNU K.F.";
  };

  # Services: Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.dates = "daily";
  virtualisation.docker.autoPrune.flags = [ "--all" "--force" "--volumes" ];

  # Containers: WG-Easy
  virtualisation.oci-containers.containers."wg-easy" = {
    image = "ghcr.io/wg-easy/wg-easy:latest";
    environment = {
      WG_HOST = "${domain}";
      WG_DEFAULT_ADDRESS = "10.10.0.x";
      WG_ALLOWED_IPS = "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16";
      WG_LANG = "en";
      UI_CHART_TYPE = "2";
      UI_TRAFFIC_STATS = "true";
      UI_ENABLE_SORT_CLIENTS = "true";
    };
    restartPolicy = "unless-stopped";
    volumes = [ "/mnt/nfs/lab/wg-easy:/etc/wireguard:rw" ];
  };
}
