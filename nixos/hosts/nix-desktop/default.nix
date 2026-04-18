{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
  ];

  networking.hostName = "nix-desktop";

  # Bootloader: systemd-boot (EFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

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
