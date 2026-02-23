{ config, pkgs, ... }:

let
  unstableTarball = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  };
  unstablePkgs = import unstableTarball {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in

{

  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader & Kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "ipv6.disable=1" ];
  boot.supportedFilesystems = [ "ntfs" ];

  # Networking & IPv6 Disable
  networking.hostName = "div-nix";
  networking.networkmanager.enable = true;

  # Locale & Timezone
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  # Keyboard & X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "winkeys";
  };
  console.keyMap = "dk-latin1";

  # Sound (Pipewire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Thunar & Services
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # User Configuration
  users.users.div = {
    isNormalUser = true;
    description = "div";
    extraGroups = [ "wheel" "networkmanager" "input" ];
  };

  # System Environment
  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Enable Sway (NixOS level)
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  nixpkgs.config.rocmSupport = true;


  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    noto-fonts
    fira-code
    nerd-fonts.fira-code
    noto-fonts-color-emoji
  ];

  environment.variables = {
    XCURSOR_THEME = "Bibata-Original-Ice";
    XCURSOR_SIZE = "24";
  };

  services.avahi = {
      enable = true;
      nssmdns4 = true; # Enables resolving .local addresses via mDNS
      openFirewall = true; # Opens port 5353/UDP for mDNS
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
  };

  environment.systemPackages = with pkgs; [
    font-manager
    arc-theme
    iconpack-obsidian
    nwg-look
    bibata-cursors

    wget
    git
    fastfetch
    btop
    tmux
    brave
    qutebrowser

    wdisplays

    mako
    wayland
    wofi
    foot
    pavucontrol
    waybar
    file-roller
    xfce.tumbler
    helix

    gcc
    gnumake
    tree-sitter
    python3
    luarocks
    lua51Packages.lua

    ripgrep
    fd
    unstablePkgs.nodejs_25
    neovim
    vesktop
    unstablePkgs.vscode-fhs

    # brightnessctl
    playerctl
    # networkmanagerapplet
    # blueman
    croc
    wpaperd
    gammastep
    grim
    slurp
    swappy
    wl-clipboard
    hyprpicker
    copyq
    linuxPackages.cpupower
  ];

  system.stateVersion = "25.11";
}