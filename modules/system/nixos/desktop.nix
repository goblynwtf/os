{ ... }:
{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./graphics.nix
    ./nix-ld.nix
  ];

  services.udisks2.enable = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="388d", ATTRS{idProduct}=="0001", GROUP="users", MODE="0660"
  '';
}
