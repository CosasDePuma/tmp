{ pkgs, lib, modulesPath, inputs, ... }: {
  # Hardware
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ./disk-configuration.nix { inherit inputs lib; device = "/dev/sda"; })
  ];

  # Administator
  users.users."root".initialPassword = "nixos";
  users.users."root".openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos@infra" ];

  # Services: SSH
  services.openssh.enable = true;
  services.openssh.ports = [ 22 ];
  services.openssh.settings.KbdInteractiveAuthentication = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.AllowUsers = [ "root" ];
}