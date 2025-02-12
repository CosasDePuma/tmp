{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in with pkgs; {
          devShells.default = mkShell {
            buildInputs = [ nixos-config nixos-rebuild ];
            shellHook = ''
              export PS1="\[\e[1;34m\]\u@\h 🏗️ \[\e[1;36m\] \w \[\e[1;32m\]➜ \[\e[1;0m\]"
            '';
          };
        }
      );
}
