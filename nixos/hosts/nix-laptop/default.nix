{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
  ];

  networking.hostName = "nix-laptop";
  networking.networkmanager.enable = true;
  users.users.div.extraGroups = [ "networkmanager" ];

  # TTY rice.
  console.font = "${pkgs.spleen}/share/consolefonts/spleen-12x24.psfu";
  console.colors = [ "01140e" "f62b5a" "47b413" "e3c401" "24acd4" "f2affd" "13c299" "e6e6e6" "616161" "ff4d51" "35d450" "e9e836" "5dc5f8" "feabf2" "24dfc4" "ffffff" ];

  # Intel GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl
      intel-vaapi-driver # Intel HD 3000
      # intel-media-driver     # Intel UHD 620
      # intel-compute-runtime  # Intel UHD 620
    ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965"; # Intel HD 3000
  # environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD"; # Intel UHD 620
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
