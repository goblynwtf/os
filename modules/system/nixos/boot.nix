{ pkgs, ... }:
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-dac4e371-be5c-4224-b2e1-e531f5affdc0".device =
    "/dev/disk/by-uuid/dac4e371-be5c-4224-b2e1-e531f5affdc0";
}
