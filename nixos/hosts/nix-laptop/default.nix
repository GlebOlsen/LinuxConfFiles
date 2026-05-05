{ config, pkgs, lib, inputs, ... }:

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

  systemd.oomd.enable = false;
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=32M
    SystemMaxUse=64M
    RateLimitBurst=5000
  '';
  boot.tmp.useTmpfs = false;
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.nixos.enable = false;

  # Compositor: Niri (Wayland)
  programs.niri.enable = true;

  # Cursor theme via dconf -> portal-gnome broadcasts to clients (niri stuff).
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "Bibata-Original-Ice";
        cursor-size = lib.gvariant.mkUint32 24;
      };
    };
  }];

  # Laptop power + hardware
  services.tlp.enable = true;
  services.thermald.enable = true;
  services.upower.enable = true;

  # Backlight + bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    swaybg
    swaylock
    swayidle
    sfwbar
    brightnessctl
    networkmanagerapplet
  ];
}
