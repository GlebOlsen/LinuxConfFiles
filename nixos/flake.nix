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
    nixpkgs-master.url = "https://github.com/NixOS/nixpkgs/archive/refs/heads/master.tar.gz";
    # Scroll: Sway fork with scrolling tiling layout (laptop test).
    scroll-flake = {
      url = "github:Diax170/scroll-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
