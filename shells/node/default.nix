{ pkgs }: with pkgs; mkShell {
  NIX_CONFIG = "experimental-features = nix-command flakes";
  buildInputs = [ nodejs_23 ];
  shellHook = ''
    export PS1="🙅🏻 \033[1;35m\u \033[1;34m\h \033[1;36m\w \033[1;32m\n➜ \033[1;0m"
  '';
}