{ inputs, lib, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./nixos/base
    ./user
    ./packages/base
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.fractal = {
    imports = [ ../home ];

    home = {
      username = "fractal";
      homeDirectory = "/home/fractal";
      stateVersion = "25.11";
    };
  };
  home-manager.extraSpecialArgs = {
    inherit inputs;
    username = "fractal";
    realname = "Arto Levi";
  };

  # Explicit unfree allowlist instead of a blanket allowUnfree, so a future
  # flake update / new dependency that pulls in an unexpected proprietary
  # package fails loudly instead of being installed silently. To regenerate:
  # temporarily set this to `pkg: true` and check the build for new names.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
      "burpsuite"
      "claude-code"
      "dbvisualizer"
      "discord"
      "google-chrome"
      "idea"
      "obsidian"
      "postman"
      "slack"
      "spotify"
      "steam"
      "steam-unwrapped"
      "sublime-merge"
      "synology-drive-client"
    ];

  system.stateVersion = "25.11";
}
