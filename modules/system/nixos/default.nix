{ ... }:
{
  imports = [
    ./boot.nix
    ./audio.nix
    ./bluetooth.nix
    ./graphics.nix
    ./locale.nix
    ./nix.nix
    ./network.nix
    ./nix-ld.nix
    ./virtualization.nix
  ];

  services.udisks2.enable = true;
}
