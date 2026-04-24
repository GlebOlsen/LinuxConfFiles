{
  inputs = {
    # Channel: unstable only
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    # Flakes
    helium = {
      url = "github:AlvaroParker/helium-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # NUR
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CachyOS kernel (binary cache via cache.garnix.io)
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
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
