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

  systemd.user.services.dms.Service.SuccessExitStatus = "143";

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
      matugenTemplateAlacritty = false;
      matugenTemplateGhostty = true;
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

      # Control Center — tiles and bar-button status icons
      controlCenterShowPrinterIcon = true;
      controlCenterShowVpnIcon = true;
      controlCenterWidgets = [
        {
          id = "wifi";
          enabled = true;
          width = 50;
        }
        {
          id = "bluetooth";
          enabled = true;
          width = 50;
        }
        {
          id = "audioInput";
          enabled = true;
          width = 50;
        }
        {
          id = "audioOutput";
          enabled = true;
          width = 50;
        }
        {
          id = "nightMode";
          enabled = true;
          width = 50;
        }
        {
          id = "darkMode";
          enabled = true;
          width = 50;
        }
        {
          id = "builtin_cups";
          enabled = true;
          width = 50;
        }
        {
          id = "builtin_vpn";
          enabled = true;
          width = 50;
        }
      ];

      # Clock — 12h, no padding, no seconds
      use24HourClock = false;
      showSeconds = false;
      padHours12Hour = false;

      # Dock — disabled
      showDock = false;

      # Bar border
      barConfigs = [
        {
          id = "default";
          name = "Main Bar";
          enabled = true;
          position = 0;
          screenPreferences = [ "all" ];
          showOnLastDisplay = true;
          leftWidgets = [
            "workspaceSwitcher"
            "focusedWindow"
          ];
          centerWidgets = [
            "music"
            "clock"
            "weather"
          ];
          rightWidgets = [
            "clipboard"
            "cpuUsage"
            "memUsage"
            "notificationButton"
            "battery"
            "controlCenterButton"
          ];
          spacing = 4;
          innerPadding = 4;
          bottomGap = 2;
          transparency = 1.0;
          widgetTransparency = 1.0;
          squareCorners = false;
          noBackground = false;
          borderEnabled = true;
          borderColor = "primary";
          borderOpacity = 1.0;
          borderThickness = 2;
        }
      ];

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

      # Fonts — Berkeley Mono and PragmataPro Mono Liga are proprietary and
      # installed outside Nix (~/.local/share/fonts). They are not in
      # fonts.packages, so a fresh machine falls back to system defaults
      # until the user copies the font files in.
      fontFamily = "Berkeley Mono";
      monoFontFamily = "PragmataPro Mono Liga";
      fontScale = 1.0;

      # Launcher
      appLauncherViewMode = "list";
      sortAppsAlphabetically = true;
      launcherLogoMode = "os";
    };
  };

  home.sessionVariables.TERMINAL = "ghostty";

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
          "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
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

  # qt5ct.conf / qt6ct.conf are intentionally NOT written here. DMS owns them
  # via its matugen templates (matugenTemplateQt5ct/Qt6ct = true above) so Qt
  # apps follow the dynamic wallpaper palette. A static Home Manager file would
  # force-replace the DMS-generated conf and drop the color_scheme wiring,
  # leaving the matugen palette orphaned.
  #
  # NOTE: environment.sessionVariables.QT_QPA_PLATFORMTHEME is set to "qt5ct"
  # in modules/system/desktop. Verify Qt6 apps (and the tray's status icons)
  # still pick up the qt6ct config + an icon theme after a rebuild; if not,
  # set the platform theme per Qt version or have DMS provide the icon theme.
}
