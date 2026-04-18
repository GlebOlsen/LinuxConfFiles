{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-25.11/nixexprs.tar.xz";
    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self,... } @inputs : {
    nixosConfigurations.div-nix = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = {
        inherit inputs;
      };
    };
  };
}