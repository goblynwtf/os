{ pkgs, ... }:
{
  imports = [
    ./bluetooth.nix
    ./hardware-configuration.nix
    ./niri-outputs.nix
    ../../modules/system
    ../../modules/system/roles/desktop
    ../../modules/system/roles/dev
    ../../modules/gaming
    ../../modules/pentest
  ];

  networking.hostName = "maple";

  # Intel I225-V (rev 01) fix: disable PCIe power saving + EEE to prevent
  # network drops. The udev rule matches the igc driver instead of a fixed
  # interface name, so the workaround survives interface-name churn.
  boot.kernelParams = [
    "pcie_aspm=off"
    "pcie_port_pm=off"
  ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", ENV{ID_NET_DRIVER}=="igc", RUN+="${pkgs.ethtool}/bin/ethtool --set-eee %k eee off"
  '';

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
}
