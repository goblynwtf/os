{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    firefox
    slack
    spotify
    thunderbird
    kdePackages.dolphin
    kdePackages.ark
    jq
    python3
    kitty
    helix
    claude-code

    bind
    binutils
    cmake
    coreutils
    file
    git
    gnumake
    gocryptfs
    htop
    mc
    i2c-tools
    p7zip
    killall
    man-pages
    nix
    nixd
    nil
    playerctl
    unixtools.xxd
    usbutils
    wpa_supplicant_gui
    xwayland-satellite
    wl-clipboard
    cups-pk-helper
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
