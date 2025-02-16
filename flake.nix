{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    snowfall.url = "github:snowfallorg/lib";
    snowfall.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { snowfall, ... } @ inputs:
    snowfall.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        name = "homelab"; namespace = "homelab";
        title = "My own IaC (Infrastructure as Code) using NixOS";

        channels-config.allowUnfree = true;
      };
    };
}
