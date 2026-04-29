{ inputs, ... }:

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

  nixpkgs = {
    overlays = [

    ];

    config = {
      allowUnfree = true;
    };
  };

  system.stateVersion = "25.11";
}
