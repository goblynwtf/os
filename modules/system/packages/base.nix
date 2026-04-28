{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    file
    git
    gocryptfs
    htop
    jq
    killall
    man-pages
    mc
    p7zip
    unixtools.xxd
    usbutils
  ];

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
