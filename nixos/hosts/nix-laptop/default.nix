{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
    inputs.scroll-flake.nixosModules.default
  ];

  # Scroll — Sway fork, scrolling tiling layout (testing).
  # Registers a separate "scroll" Wayland session; existing Sway stays as fallback.
  programs.scroll = {
    enable = true;
    wrapperFeatures.gtk = true;
    # Bleeding-edge instead of stable 1.12.15 — uncomment to swap:
    # package = inputs.scroll-flake.packages.${pkgs.stdenv.hostPlatform.system}.scroll-git;
  };

  networking.hostName = "nix-laptop";
  networking.networkmanager.enable = true;
  users.users.div.extraGroups = [ "networkmanager" ];

  # TTY rice.
  console.font = "${pkgs.spleen}/share/consolefonts/spleen-12x24.psfu";
  console.colors = [ "01140e" "f62b5a" "47b413" "e3c401" "24acd4" "f2affd" "13c299" "e6e6e6" "616161" "ff4d51" "35d450" "e9e836" "5dc5f8" "feabf2" "24dfc4" "ffffff" ];

  # Intel GPU:
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vpl-gpu-rt
      intel-compute-runtime
      libvdpau-va-gl
    ];
  };
  hardware.enableRedistributableFirmware = true;

  # BIOS alternative:
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    configurationLimit = 10;
  };

  # Laptop power + hardware
  services.tlp.enable = true;
  services.thermald.enable = true;
  services.upower.enable = true;

  # Backlight + bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    networkmanagerapplet
    intel-gpu-tools # intel_gpu_top monitor
  ];
}
