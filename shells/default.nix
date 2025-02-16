{ pkgs }:
  pkgs.lib.pipe (builtins.readDir ./.) [
    builtins.attrNames
    (builtins.filter (file: pkgs.lib.strings.hasSuffix ".nix" file))
    (builtins.filter (file: file != "default.nix"))
    (builtins.map (file: {
      name = pkgs.lib.removeSuffix ".nix" file;
      value = import (./. + "/${file}") { inherit pkgs; };
    }))
    builtins.listToAttrs
  ]