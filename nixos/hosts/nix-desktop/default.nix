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

  # External monitor brightness control via DDC/CI.
  hardware.i2c.enable = true;
  services.ddccontrol.enable = true;

  environment.systemPackages = with pkgs; [
    amdgpu_top
    ddcutil
  ];
}
