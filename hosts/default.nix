{ nixpkgs, system ? "x86_64-linux", disko ? null }:
  let
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in
    nixpkgs.lib.pipe (builtins.readDir ./.) [
      builtins.attrNames
      (builtins.filter (path: nixpkgs.lib.strings.hasSuffix ".nix" path))
      (builtins.filter (path: ! builtins.elem path [ "common.nix" "default.nix" ]))
      (builtins.map (path: {
        name = nixpkgs.lib.removeSuffix ".nix" path;
        value = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            disko.nixosModules.disko
            ../modules
            (./. + "/${path}")
          ];
        };
      }))
      builtins.listToAttrs
    ] // {
      minimal = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          disko.nixosModules.disko
          ../modules/minimal.nix
        ];
      };
    }