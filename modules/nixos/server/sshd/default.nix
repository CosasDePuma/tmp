{ config, lib, ... }: {
  config = lib.mkIf config.services.openssh.enable {
    services.openssh.ports = lib.mkDefault [ 10022 ];
    services.openssh.openFirewall = lib.mkDefault true;
    services.openssh.authorizedKeysInHomedir = lib.mkDefault false;
    services.openssh.settings.KbdInteractiveAuthentication = lib.mkDefault false;
    services.openssh.settings.PasswordAuthentication = lib.mkDefault false;
    services.openssh.settings.PermitRootLogin = lib.mkDefault "no";
    services.openssh.settings.X11Forwarding = lib.mkDefault false;
    services.openssh.banner = lib.mkDefault ''
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
    security.pam.sshAgentAuth.enable = lib.mkDefault true;
    security.pam.sshAgentAuth.authorizedKeysFiles = lib.mkDefault [ "/etc/ssh/authorized_keys.d/%u" ];
    security.pam.services.sudo.sshAgentAuth = lib.mkDefault true;
  };
}