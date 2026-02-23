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

  # Enable Sway (NixOS level)
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      wayland
      waybar

      wofi

      mako

      foot

      wdisplays
      wpaperd
      gammastep
      
      grim
      slurp
      swappy
      wl-clipboard
      copyq
      
      hyprpicker
    ];
  };

  # System Environment
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true; # For btop GPU monitoring

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.variables = {
    XCURSOR_THEME = "Bibata-Original-Ice";
    XCURSOR_SIZE = "24";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    noto-fonts
    fira-code
    nerd-fonts.fira-code
    noto-fonts-color-emoji
  ];

  # User Configuration
  users.users.div = {
    isNormalUser = true;
    description = "div";
    extraGroups = [ "wheel" "networkmanager" "input" ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # System
    nmap
    wget
    git
    fastfetch
    btop
    tmux
    ripgrep
    fd
    croc
    linuxPackages.cpupower

    # Development
    gcc
    gnumake
    tree-sitter
    python3
    luarocks
    lua51Packages.lua
    unstablePkgs.nodejs_25
    tailscale

    # Editors
    helix
    neovim
    micro
    unstablePkgs.vscode-fhs
    meld

    # Internet
    brave
    qutebrowser
    # vivaldi

    # Communication
    vesktop
    # Need to add Matrix.org stuff

    # File Management
    file-roller
    xfce.tumbler

    # Audio
    pavucontrol
    playerctl

    # Theming
    font-manager
    arc-theme
    iconpack-obsidian
    nwg-look
    bibata-cursors

    # Laptop Stuff (Not finished):
    # brightnessctl
    # networkmanagerapplet
    # blueman
  ];

  system.stateVersion = "25.11";
}