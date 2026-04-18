{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
  ];

  networking.hostName = "nix-laptop";

  # Bootloader: GRUB
  # EFI system (default assumption). If laptop is legacy BIOS, comment EFI block
  # and uncomment the BIOS block below (set correct disk device).
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # BIOS alternative:
  # boot.loader.grub = {
  #   enable = true;
  #   device = "/dev/sda";   # set to actual disk, NOT a partition
  #   useOSProber = true;
  #   configurationLimit = 10;
  # };

  # Compositor: Niri (Wayland)
  programs.niri.enable = true;

  # Laptop power + hardware
  services.tlp.enable = true;
  services.thermald.enable = true;
  services.upower.enable = true;

  # Backlight + bluetooth
  programs.light.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    ironbar
    brightnessctl
    networkmanagerapplet
  ];
}
