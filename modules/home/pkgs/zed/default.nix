{ ... }:
{
  home.sessionVariables = {
    EDITOR = "zeditor --wait";
    VISUAL = "zeditor --wait";
  };

  programs.zed-editor = {
    enable = true;

    extensions = [
      "go"
      "html"
      "java"
      "marksman"
      "nix"
      "ruby"
      "rust"
    ];

    mutableUserSettings = false;
    mutableUserKeymaps = false;
    mutableUserTasks = false;

    userSettings = {
      agent_servers = {
        codex-acp = {
          type = "registry";
        };
      };
      base_keymap = "Emacs";
      vim_mode = false;
      theme = {
        mode = "dark";
        dark = "One Dark";
        light = "One Light";
      };
      buffer_font_family = "PragmataPro Mono Liga";
      ui_font_size = 17;
      buffer_font_size = 16;

      autosave = "off";
      ensure_final_newline_on_save = true;
      format_on_save = "on";
      formatter = "auto";
      preferred_line_length = 100;
      remove_trailing_whitespace_on_save = true;
      show_completion_documentation = true;
      show_completions_on_input = true;
      show_edit_predictions = false;
      show_whitespaces = "selection";
      soft_wrap = "none";
      tab_size = 2;
      use_autoclose = true;

      session = {
        trust_all_worktrees = false;
      };
      tabs = {
        file_icons = true;
        git_status = true;
        show_diagnostics = "all";
      };
      terminal = {
        alternate_scroll = "on";
        blinking = "off";
        dock = "bottom";
        env = {
          EDITOR = "zeditor --wait";
          VISUAL = "zeditor --wait";
        };
        font_family = "PragmataPro Mono Liga";
        working_directory = "current_project_directory";
      };
      global_lsp_settings = {
        request_timeout = 120;
        notifications = {
          dismiss_timeout_ms = 5000;
        };
      };
      lsp = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true;
              staticcheck = true;
            };
          };
        };
        rust-analyzer = {
          initialization_options = {
            check = {
              command = "clippy";
            };
          };
        };
      };
      languages = {
        Nix = {
          formatter = {
            external = {
              command = "nixfmt";
              arguments = [ ];
            };
          };
          language_servers = [
            "nixd"
            "!nil"
            "..."
          ];
          tab_size = 2;
        };
        Rust = {
          formatter = "language_server";
          language_servers = [
            "rust-analyzer"
            "..."
          ];
          tab_size = 4;
        };
        Go = {
          formatter = "language_server";
          tab_size = 4;
        };
        Java = {
          formatter = "language_server";
          tab_size = 4;
        };
        Ruby = {
          formatter = "language_server";
          language_servers = [
            "ruby-lsp"
            "!solargraph"
            "..."
          ];
          tab_size = 2;
        };
        HTML = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
          tab_size = 2;
        };
        Markdown = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
          preferred_line_length = 80;
          remove_trailing_whitespace_on_save = false;
          soft_wrap = "preferred_line_length";
          tab_size = 2;
        };
        "Shell Script" = {
          tab_size = 2;
        };
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          ctrl-shift-t = "workspace::NewTerminal";
        };
      }
    ];

    userTasks = [
      {
        label = "nix flake check";
        command = "nix";
        args = [
          "flake"
          "check"
        ];
        reveal = "always";
      }
      {
        label = "nixos build current host";
        command = "bash";
        args = [
          "-lc"
          "nixos-rebuild build --flake .#$(hostname)"
        ];
        reveal = "always";
      }
    ];
  };

  xdg.configFile = {
    "zed/settings.json".force = true;
    "zed/keymap.json".force = true;
    "zed/tasks.json".force = true;
  };
}
