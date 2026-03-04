{ pkgs, ... }:

{
  services.dbus.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.enable = true;

    extraConfig.pipewire = {
      "context.properties" = {
        "link.max-buffers" = 16;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = { };
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
  ];
}
