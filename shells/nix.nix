{ pkgs }: with pkgs; mkShell {
  buildInputs = [ nixos-rebuild ];
  shellHook = ''
    export PS1="⛄️ \033[1;35m\u \033[1;34m\h \033[1;36m\w \033[1;32m\n➜ \033[1;0m"
    alias nixos-remote-switch="${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --use-remote-sudo --target-host";
  '';
}