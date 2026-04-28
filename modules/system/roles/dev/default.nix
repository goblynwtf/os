{ lib, ... }:
{
  imports = [
    ../../nixos/virtualization.nix
    ../../packages/dev.nix
  ];

  users.users.fractal.extraGroups = lib.mkAfter [ "docker" ];
}
