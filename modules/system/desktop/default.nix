{ pkgs, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
  };

  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us,ru";
    xkb.options = "";

    autoRepeatDelay = 300;
    autoRepeatInterval = 25;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  programs.niri.enable = true;
  services.libinput.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    ubuntu-classic
    nerd-fonts.ubuntu-mono
    lmodern
  ];
}
