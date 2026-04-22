{ ... }:
{
  programs.nushell = {
    enable = true;

    shellAliases = {
      ls = "eza";
      ll = "eza -l --git";
      la = "eza -la --git";
      lt = "eza --tree --level=2";
      cat = "bat";
      e = "zeditor";
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";
      flake-update = "nix flake update";
      flake-check = "nix flake check";
      nd = "nix develop -c nu";
      nsh = "nix-shell --command nu";
    };

    extraConfig = ''
      $env.config.show_banner = false

      def rebuild [] { sudo nixos-rebuild switch --flake $".#(^hostname | str trim)" }
      def rebuild-build [] { nixos-rebuild build --flake $".#(^hostname | str trim)" }
    '';
  };

  programs.direnv.enableNushellIntegration = true;
}
