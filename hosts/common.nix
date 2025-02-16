{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  # System
  system.stateVersion = pkgs.lib.mkDefault "24.11";
  system.copySystemConfiguration = pkgs.lib.mkDefault true;
  nixpkgs.config.allowUnfree = pkgs.lib.mkDefault true;

  # Boot
  boot.loader.grub.enable = pkgs.lib.mkDefault true;
  boot.loader.grub.device = pkgs.lib.mkDefault "/dev/sda";

  # DNS
  networking.nameservers = pkgs.lib.mkDefault [ "1.1.1.1" "8.8.8.8" ];

  # Network interfaces
  networking.usePredictableInterfaceNames = pkgs.lib.mkDefault false;

  # Firewall
  networking.firewall.enable = pkgs.lib.mkDefault true;
  networking.firewall.allowedTCPPorts = pkgs.lib.mkDefault [ ];
  networking.firewall.allowedUDPPorts = pkgs.lib.mkDefault [ ];

  # Localization
  time.timeZone = pkgs.lib.mkDefault  "Europe/Madrid";

  # Packages
  environment.systemPackages = with pkgs; pkgs.lib.mkDefault [ nano ];

  # Users
  users.groups."users" = pkgs.lib.mkDefault {};

  # Maintenance: System GC
  nix.gc.automatic = pkgs.lib.mkDefault  true;
  nix.gc.dates = pkgs.lib.mkDefault "weekly";
  nix.gc.options = pkgs.lib.mkDefault "--delete-older-than 7d";
  nix.gc.persistent = pkgs.lib.mkDefault true;

  # Maintenance: System autoupgrade
  system.autoUpgrade.enable = pkgs.lib.mkDefault  true;
  system.autoUpgrade.allowReboot = pkgs.lib.mkDefault true;
  system.autoUpgrade.persistent = pkgs.lib.mkDefault true;
  system.autoUpgrade.dates = pkgs.lib.mkDefault "weekly";

  # Maintenance: Journald
  services.journald.storage = pkgs.lib.mkDefault "persistent";
  services.journald.extraConfig = pkgs.lib.mkDefault ''
    MaxRetentionSec="1month"
    RuntimeMaxUse="1G"
    SystemMaxUse="2G"
  '';

  # Services: SSH
  services.openssh.enable = pkgs.lib.mkDefault true;
  services.openssh.ports = pkgs.lib.mkDefault [ 9022 ];
  services.openssh.openFirewall = pkgs.lib.mkDefault true;
  services.openssh.authorizedKeysInHomedir = pkgs.lib.mkDefault false;
  services.openssh.settings.KbdInteractiveAuthentication = pkgs.lib.mkDefault false;
  services.openssh.settings.PasswordAuthentication = pkgs.lib.mkDefault false;
  services.openssh.settings.PermitRootLogin = pkgs.lib.mkDefault "no";
  services.openssh.settings.X11Forwarding = pkgs.lib.mkDefault false;
  services.openssh.banner = pkgs.lib.mkDefault ''
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
  security.pam.sshAgentAuth.enable = pkgs.lib.mkDefault true;
  security.pam.sshAgentAuth.authorizedKeysFiles = pkgs.lib.mkDefault [ "/etc/ssh/authorized_keys.d/%u" ];
  security.pam.services.sudo.sshAgentAuth = pkgs.lib.mkDefault true;

  # Services: Fail2Ban
  services.fail2ban.enable = pkgs.lib.mkDefault true;
  services.fail2ban.maxretry = pkgs.lib.mkDefault 3;
  services.fail2ban.bantime = pkgs.lib.mkDefault "30d";
}
