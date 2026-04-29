{ ... }:
{
  imports = [
    ../../nixos/virtualization
    ../../packages/dev
  ];

  users.users.fractal.extraGroups = [ "docker" ];
}
