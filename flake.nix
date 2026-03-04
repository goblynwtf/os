{
  description = "Personal Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      args = { inherit inputs; };
      system = "x86_64-linux";

      feywild = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/feywild ];
        specialArgs = args;
      };
    in
    {
      nixosConfigurations = {
        inherit feywild;
      };
    };

}
