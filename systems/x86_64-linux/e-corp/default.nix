{ lib, namespace, ... }:
let
  disk    = "/dev/sda";
  user    = "elliot";
  root_pw = "Sg7ORsv^WN2v8M";
  ssh_pub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos@infra";
  ip_priv = "192.168.1.2";
  ip_gw   = lib.concatStringsSep "." ((lib.take 3 (lib.splitString "." ip_priv)) ++ [ "1" ]);
in
{
  # Hardware
  ${namespace}.hardware.disk = "/dev/sda";
  #${namespace}.hardware.vm = true;

  # Networking
  networking.hostName = "e-corp";
  networking.interfaces."eth0".ipv4.addresses = [{ address = ip_priv; prefixLength = 24; }];
  networking.defaultGateway.interface = "eth0";
  networking.defaultGateway.address = ip_gw;

  # User
  users.users."root".initialPassword = root_pw;
  users.users."${user}" = {
    description = "Hello, friend.";
    createHome = false;
    password = null;
    isSystemUser = true;
    group = "users";
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ ssh_pub ];
  };
  services.openssh.settings.AllowUsers = [ user ];

  # Services: SSH
  services.openssh.enable = true;
  services.fail2ban.enable = true;
}