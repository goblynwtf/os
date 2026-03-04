{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    slack
    spotify
    steam
    thunderbird
    devenv

    bind
    binutils
    cmake
    coreutils
    file
    git
    gnumake
    gocryptfs
    htop
    i2c-tools
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

    bibata-cursors
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.xwayland.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

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
