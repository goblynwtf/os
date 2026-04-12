{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      # eza
      ls = "eza";
      ll = "eza -l --git";
      la = "eza -la --git";
      lt = "eza --tree --level=2";

      # NixOS rebuild
      rebuild = "sudo nixos-rebuild switch --flake .#(hostname)";
      rebuild-build = "nixos-rebuild build --flake .#(hostname)";
      flake-update = "nix flake update";
      flake-check = "nix flake check";

      # Git
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";
    };

    shellAliases = {
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      cat = "bat";
    };

    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];

    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
}
