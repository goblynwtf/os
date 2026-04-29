let
  ezaAliases = import ../shell-aliases.nix;
in
{
  programs.bash = {
    enable = true;

    shellAliases = ezaAliases // {
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
