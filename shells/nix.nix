{ pkgs }: with pkgs; mkShell {
  buildInputs = [ nixos-anywhere nixos-rebuild ];
  shellHook = ''
    export PS1="⛄️ \033[1;35m\u \033[1;34m\h \033[1;36m\w \033[1;32m\n➜ \033[1;0m"

    remote-switch() {
      git add .
      nixos-rebuild switch \
        --target-host "$1" --use-remote-sudo \
        --build-host "$1" --fast \
        --flake .#
    }

    remote-minimal() {
      nixos-anywhere --generate-hardware-config \
        nixos-generate-config ./hardware-configuration.nix \
        --build-on-remote "$1" \
        --flake .#minimal
    }
  '';
}