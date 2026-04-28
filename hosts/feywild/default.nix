{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/system/roles/desktop
    ../../modules/system/roles/dev
    ../../modules/system/roles/work
  ];

  networking.hostName = "feywild";

  # LUKS swap unlock (host-specific)
  boot.initrd.luks.devices."luks-dac4e371-be5c-4224-b2e1-e531f5affdc0".device =
    "/dev/disk/by-uuid/dac4e371-be5c-4224-b2e1-e531f5affdc0";
}
