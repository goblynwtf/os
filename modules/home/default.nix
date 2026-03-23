{ ... }:
{
  imports = [
    ./desktop
    ./pkgs
  ];

  programs.home-manager.enable = true;

  services.home-manager.autoExpire = {
    enable = true;
    frequency = "weekly";
    timestamp = "-7 days";
  };
}
