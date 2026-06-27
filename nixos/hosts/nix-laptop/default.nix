{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
  ];

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/3b629e27-78b1-4e43-9dd9-4720bb689a12";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';

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
       intel-media-driver
    ];
  };
  hardware.enableRedistributableFirmware = true;
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

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
    intel-gpu-tools
  ];
}
