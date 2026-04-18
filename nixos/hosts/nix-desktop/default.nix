{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
  ];

  networking.hostName = "nix-desktop";

  # AMD GPU
  nixpkgs.config.rocmSupport = true;

  # Compositor: Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    amdgpu_top
  ];
}
