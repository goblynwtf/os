{ ... }:
{
  programs.nushell = {
    enable = true;

    shellAliases = {
      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";

      # Flake shortcuts
      nfu = "nix flake update";
      nfc = "nix flake check";

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
