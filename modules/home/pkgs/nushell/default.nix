let
  sharedAliases = import ../shell-aliases.nix;
in
{
  programs.nushell = {
    enable = true;

    shellAliases = sharedAliases // {
      # Nushell-specific shortcuts (rebuild/rebuild-build live in commands.nu)
      nfu = "nix flake update";
      nfc = "nix flake check";
      zj = "zellij";
    };

    extraConfig = ''
      $env.config.show_banner = false

      use ~/.config/nushell/commands.nu *
      source ~/.config/nushell/prompt.nu
    '';
  };

  home.file.".config/nushell/commands.nu".source = ./commands.nu;
  home.file.".config/nushell/prompt.nu".source = ./prompt.nu;
}
