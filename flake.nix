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
            buildInputs = [ nixos-rebuild ];
            shellHook = ''
              export PS1="\033[1;34m\u@\h 🏗️ \033[1;36m \w \033[1;32m\n➜ \033[1;0m"
              alias nixos-remote-switch="${nixos-rebuild}/bin/nixos-rebuild switch --use-remote-sudo --target-host";
            '';
          };
        }
      );
}
