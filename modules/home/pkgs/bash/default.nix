{ ... }:
{
  programs.bash = {
    enable = true;

    shellAliases = {
      # ls replacements (eza)
      ls = "eza";
      ll = "eza -l --git";
      la = "eza -la --git";
      lt = "eza --tree --level=2";

      # NixOS rebuild shortcuts
      rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";
      rebuild-build = "nixos-rebuild build --flake .#$(hostname)";
      flake-update = "nix flake update";
      flake-check = "nix flake check";

      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";

      # Editor
      e = "zeditor";

      # Safety
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
    };
  };
}
