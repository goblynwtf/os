{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Optional include so Ghostty still starts before DMS generates the theme file.
      config-file = "?themes/dankcolors";

      font-family = "Fantasque Sans Mono";
      font-size = 13;
      bold-is-bright = true;

      window-decoration = false;
      window-padding-x = 12;
      window-padding-y = 12;
      background-opacity = 0.85;

      # Scrollback buffer size in BYTES (not lines); ~10 MB.
      scrollback-limit = 10000000;

      cursor-style = "block";
      cursor-style-blink = true;

      mouse-hide-while-typing = true;
      copy-on-select = false;

      shell-integration = "nushell";
      clipboard-paste-protection = true;
      confirm-close-surface = false;

      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+n=new_window"
        "ctrl+shift+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"
        "shift+enter=text:\\n"
      ];
    };
  };
}
