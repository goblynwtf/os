{ ... }:
{
  users.users.fractal = {
    isNormalUser = true;
    description = "fractal";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
      "networkmanager"
      "audio"
      "video"
    ];
  };
}
