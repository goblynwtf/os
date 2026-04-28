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
}
