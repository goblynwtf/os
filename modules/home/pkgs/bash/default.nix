let
  sharedAliases = import ../shell-aliases.nix;
in
{
  programs.bash = {
    enable = true;

    shellAliases = sharedAliases // {
      # NixOS rebuild shortcuts (bash-specific; nushell uses commands.nu)
      rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";
      rebuild-build = "nixos-rebuild build --flake .#$(hostname)";
      flake-update = "nix flake update";
      flake-check = "nix flake check";

      # Safety
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
    };
  };
}
