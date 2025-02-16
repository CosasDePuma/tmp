{ lib, ... }:
let
  user    = "elliot";
  ip_priv = "192.168.1.2";
  ip_gw   = lib.concatStringsSep "." ((lib.take 3 (lib.splitString "." ip_priv)) ++ [ "1" ]);
  ssh_pub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos@infra";
in
{
  # Networking
  networking.hostName = "e-corp";
  networking.interfaces."eth0".ipv4.addresses = [{ address = ip_priv; prefixLength = 24; }];
  networking.defaultGateway.interface = "eth0";
  networking.defaultGateway.address = ip_gw;

  # User
  users.groups."users" = lib.mkDefault {};
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
}