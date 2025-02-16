{ pkgs, lib, modulesPath, ... }: {
    # Hardware
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Boot
  boot.loader.grub.enable = lib.mkDefault true;
  boot.loader.grub.efiSupport = lib.mkDefault true;
  boot.loader.grub.efiInstallAsRemovable = lib.mkDefault true;

  # System packages
  system.stateVersion = lib.mkDefault "24.05";
  environment.systemPackages = with pkgs; lib.mkDefault [ curl gitMinimal nano neovim ];

  # Services: SSH
  services.openssh.enable = lib.mkDefault true;
  services.openssh.ports = lib.mkDefault [ 22 ];
  services.openssh.openFirewall = lib.mkDefault true;
  services.openssh.authorizedKeysInHomedir = pkgs.lib.mkDefault false;
  services.openssh.settings.KbdInteractiveAuthentication = lib.mkDefault false;
  services.openssh.settings.PasswordAuthentication = lib.mkDefault false;
  services.openssh.settings.PermitRootLogin = lib.mkDefault "prohibit-password";
  services.openssh.settings.X11Forwarding = lib.mkDefault false;
  security.pam.sshAgentAuth.enable = pkgs.lib.mkDefault true;
  security.pam.sshAgentAuth.authorizedKeysFiles = pkgs.lib.mkDefault [ "/etc/ssh/authorized_keys.d/%u" ];
  security.pam.services.sudo.sshAgentAuth = pkgs.lib.mkDefault true;
  services.openssh.settings.AllowUsers = lib.mkDefault [ "root" ];

  # Administator
  users.users."root".initialPassword = lib.mkDefault "nixos";
  users.users."root".openssh.authorizedKeys.keys = lib.mkDefault [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos@infra" ];

  # Disks
  disko.devices.disk.disk1 = {
    device = lib.mkDefault "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          name = "BOOT";
          size = "1M";
          type = "EF02";
        };
        esp = {
          name = "ESP";
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          name = "ROOT";
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}