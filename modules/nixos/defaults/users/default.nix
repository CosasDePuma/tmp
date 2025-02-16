{ config, lib, ... }: {
  config.users.groups."users" = lib.mkDefault {};
}