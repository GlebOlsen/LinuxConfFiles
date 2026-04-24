{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
  ];

  networking.hostName = "nix-laptop";

  # BIOS alternative:
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    configurationLimit = 10;
  };

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
