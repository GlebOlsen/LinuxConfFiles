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
    # Bleeding-edge nixpkgs master (used only for claude-code + codex).
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # CachyOS kernel with prebuilt binary cache (garnix + lantian).
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
