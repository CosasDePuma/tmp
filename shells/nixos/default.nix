{ pkgs }: with pkgs; mkShell {
  NIX_CONFIG = "experimental-features = nix-command flakes";
  buildInputs = [ nixos-anywhere nixos-rebuild ];
  shellHook = ''
    export PS1="⛄️ \033[1;35m\u \033[1;34m\h \033[1;36m\w \033[1;32m\n➜ \033[1;0m"

    remote-switch() {
      git add .
      host="$1"; shift
      nixos-rebuild switch \
        --target-host "$host" --use-remote-sudo \
        --build-host "$host" --fast \
        --flake .# $@
    }

    remote-minimal() {
      host="$1"; shift
      nixos-anywhere \
        --build-on-remote "$host" \
        --flake .#minimal $@
    }
  '';
}