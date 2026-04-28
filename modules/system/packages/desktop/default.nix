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

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "fractal" ];
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        brave
        firefox
        chromium
      '';
      mode = "0755";
    };
  };
}
