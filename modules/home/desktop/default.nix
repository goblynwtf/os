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

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "NetworkManager secret agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
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
      enable = true;
      restartIfChanged = true;
    };

    enableDynamicTheming = true;
    enableSystemMonitoring = true;
    enableAudioWavelength = true;
    enableVPN = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;

    settings = {
      # Theming — dynamic wallpaper-based colors via matugen
      currentThemeName = "dynamic";
      currentThemeCategory = "dynamic";
      matugenScheme = "scheme-tonal-spot";
      runDmsMatugenTemplates = true;
      runUserMatugenTemplates = true;
      matugenTemplateAlacritty = true;
      matugenTemplateNiri = true;
      matugenTemplateFirefox = true;
      matugenTemplateGtk = true;
      matugenTemplateQt5ct = true;
      matugenTemplateQt6ct = true;
      cornerRadius = 12;
      popupTransparency = 1.0;
      enableRippleEffects = true;

      # Animations
      animationSpeed = 1; # Short
      syncComponentAnimationSpeeds = true;

      # Panel widgets — all enabled
      showLauncherButton = true;
      showWorkspaceSwitcher = true;
      showFocusedWindow = true;
      showWeather = true;
      showMusic = true;
      showClipboard = true;
      showCpuUsage = true;
      showMemUsage = true;
      showCpuTemp = true;
      showGpuTemp = true;
      showSystemTray = true;
      showClock = true;
      showNotificationButton = true;
      showBattery = true;
      showControlCenterButton = true;
      showCapsLockIndicator = true;

      # Clock — 12h, no padding, no seconds
      use24HourClock = false;
      showSeconds = false;
      padHours12Hour = false;

      # Dock — disabled
      showDock = false;

      # Notifications — bottom-right, compact, with history
      notificationPopupPosition = 3; # Right = bottom-right
      notificationCompactMode = true;
      notificationHistoryEnabled = true;

      # Power management
      acSuspendBehavior = 0; # Suspend
      batterySuspendBehavior = 0; # Suspend
      lockBeforeSuspend = true;
      nightModeEnabled = true;

      # Lock screen — everything visible
      lockScreenShowTime = true;
      lockScreenShowDate = true;
      lockScreenShowProfileImage = true;
      lockScreenShowMediaPlayer = true;
      lockScreenShowPowerActions = true;
      lockScreenShowSystemIcons = true;
      lockScreenShowPasswordField = true;

      # Fonts
      fontFamily = "Berkeley Mono";
      monoFontFamily = "PragmataPro Mono Liga";
      fontScale = 1.0;

      # Launcher
      appLauncherViewMode = "list";
      sortAppsAlphabetically = true;
      launcherLogoMode = "os";
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
          koodo = "koodo-reader.desktop";
        in
        {
          "application/epub+zip" = koodo;
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
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    gtk4.theme = null;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };
}
