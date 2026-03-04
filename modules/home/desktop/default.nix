{ pkgs, inputs, ... }:
{
  systemd.user.services.polkit-agent = {
    Unit = {
      Description = "Polkit Authentication Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;

    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications =
        let
          firefox = "firefox.desktop";
          slack = "slack.desktop";
        in
        {
          "application/pdf" = firefox;
          "application/x-extension-htm" = firefox;
          "application/x-extension-html" = firefox;
          "application/x-extension-shtml" = firefox;
          "application/x-extension-xht" = firefox;
          "application/x-extension-xhtml" = firefox;
          "application/xhtml+xml" = firefox;
          "image/jpeg" = firefox;
          "image/png" = firefox;
          "text/html" = firefox;
          "text/uri-list" = firefox;
          "x-scheme-handler/slack" = slack;
          "x-scheme-handler/chrome" = firefox;
          "x-scheme-handler/http" = firefox;
          "x-scheme-handler/https" = firefox;
        };
    };
    configFile."mimeapps.list".force = true;
  };

  gtk = {
    enable = true;
  };
}
