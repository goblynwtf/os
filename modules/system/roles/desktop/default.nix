{ ... }:
{
  imports = [
    ../../desktop
    ../../nixos/desktop
    ../../packages/desktop
  ];

  home-manager.users.fractal.imports = [
    ../../../home/desktop
    ../../../home/niri
  ];
}
