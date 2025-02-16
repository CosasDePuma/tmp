{ pkgs, lib, modulesPath, inputs, ... }: {
  # Hardware
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    (import ./disk-configuration.nix { inherit inputs lib; device = "/dev/sda"; })
  ];

  # Boot
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  # System packages
  system.stateVersion = "24.05";
  environment.systemPackages = with pkgs; [ curl gitMinimal nano neovim ];

  # Services: SSH
  services.openssh.enable = true;
  services.openssh.ports = [ 22 ];
  services.openssh.openFirewall = true;
  services.openssh.authorizedKeysInHomedir = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.X11Forwarding = false;
  security.pam.sshAgentAuth.enable = true;
  security.pam.sshAgentAuth.authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
  security.pam.services.sudo.sshAgentAuth = true;
  services.openssh.settings.AllowUsers = [ "root" ];

  # Administator
  users.users."root".initialPassword = "nixos";
  users.users."root".openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos@infra" ];
}