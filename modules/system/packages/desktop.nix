{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cups-pk-helper
    file-roller
    firefox
    kitty
    nautilus
    playerctl
    spotify
    thunderbird
    wl-clipboard
    wpa_supplicant_gui
    xwayland-satellite
  ];

  programs.xwayland.enable = true;
}
