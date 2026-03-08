{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self,... } @inputs : {
    nixosConfigurations.div-nix = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./modules/configuration.nix ];
      specialArgs = {
        inherit inputs;
      };
    };
  };
}
