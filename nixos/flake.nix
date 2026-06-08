{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
    # Bleeding-edge nixpkgs master
    nixpkgs-master.url = "https://github.com/NixOS/nixpkgs/archive/refs/heads/master.tar.gz";
  };

  outputs = { self, ... } @inputs:
    let
      mkHost = hostPath:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ hostPath ];
          specialArgs = { inherit inputs; };
        };
    in
    {
      nixosConfigurations = {
        nix-desktop = mkHost ./hosts/nix-desktop;
        nix-laptop = mkHost ./hosts/nix-laptop;
      };
    };
}
