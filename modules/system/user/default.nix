{ pkgs, ... }:
{
  users.users.fractal = {
    isNormalUser = true;
    description = "fractal";
    shell = pkgs.nushell;
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "audio"
      "video"
    ];
  };

  environment.shells = [
    pkgs.nushell
    pkgs.bashInteractive
  ];
}
