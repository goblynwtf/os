{ ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [ "ruby" "go" "java" "nix" "rust" "html" ];

    mutableUserSettings = true;
    mutableUserKeymaps = true;

    userSettings = {
      base_keymap = "Atom";
      theme = {
        mode = "dark";
        dark = "One Dark";
        light = "One Light";
      };
      ui_font_size = 16;
      buffer_font_size = 15;
      session = {
        trust_all_worktrees = true;
      };
    };
  };
}
