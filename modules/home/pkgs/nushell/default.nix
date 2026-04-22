{ ... }:
{
  programs.nushell = {
    enable = true;

    shellAliases = {
      # ls replacements (eza)
      ls = "eza";
      ll = "eza -l --git";
      la = "eza -la --git";
      lt = "eza --tree --level=2";

      # Editor
      e = "zeditor";

      # File viewing
      cat = "bat";

      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";

      # Flake shortcuts
      flake-update = "nix flake update";
      flake-check = "nix flake check";

      # Nix shells
      nd = "nix develop -c nu";
      nsh = "nix-shell --command nu";
    };

    extraConfig = ''
      $env.config.show_banner = false

      def rebuild [] { sudo nixos-rebuild switch --flake $".#(sys host | get hostname)" }
      def rebuild-build [] { nixos-rebuild build --flake $".#(sys host | get hostname)" }
    '';
  };
}
