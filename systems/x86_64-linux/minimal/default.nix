{ namespace, ... }: {
  "${namespace}" = {
    # Hardware
    hardware.disk = "/dev/sda";
    hardware.isVM = false;

    # i18n
    i18n.timezone = "Europe/Madrid";

    # Networking
    networking.hostName = "minimal";
    networking.ipv4 = "192.168.1.2";

    # System
    nix.gc.enable = true;
    nixos.followFlake = "github:cosasdepuma/tmp";

    # Users
    users.administrator.username = "elliot";
    users.administrator.description = "Hello, friend.";
    users.administrator.sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9RzisL6wVQK3scDyEPEpFgrcdFYkW9LssnWlORGXof nixos@infra";

    # ---- Services

    # Fail2Ban
    services.fail2ban.enable = true;

    # NFS Client
    services.nfs.client.server = "192.168.1.252:/mnt/nfs";
    services.nfs.client.mountpoint = "/mnt/nfs";

    # SSHd
    services.sshd.enable = true;
    services.sshd.port = 10022;
  };
}