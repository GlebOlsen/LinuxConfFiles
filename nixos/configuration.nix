{ config, pkgs, inputs, ... }:

let
  unstableTarball = builtins.fetchTarball {
    url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  };
  unstablePkgs = import unstableTarball {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in
{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
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

  documentation.enable = false;

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
    plugins = with pkgs; [
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
  };

  # System Environment
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true; # For btop AMD GPU monitoring

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

  programs.nh = {
    enable = true;
    flake = "$HOME/repo/linuxconffiles/nixos";
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    # System
    wl-kbptr
    nmap
    dysk
    wget
    git
    yazi
    tmux
    fish
    mako
    lazygit
    amdgpu_top
    fastfetch
    btop
    croc
    linuxPackages.cpupower
    ironbar

    # Terminal
    foot

    # Display
    wdisplays
    wpaperd
    gammastep

    # Clip/Screen/Extras
    grim
    slurp
    swappy
    wl-clipboard
    copyq
    hyprpicker

    # Development
    gcc
    gnumake
    ripgrep
    fd
    tree-sitter
    python3
    luarocks
    lua51Packages.lua
    nodejs_25
    nim

    # Editors
    neovim
    helix
    micro
    vscode-fhs # (need to build myself...)
    # github-copilot-cli (need to build myself...)
    opencode # (need to build myself...)
    meld
    # zed-editor-fhs

    # Internet
    inputs.helium.packages.${ pkgs.stdenv.hostPlatform.system }.helium
    tailscale
    mullvad
    # brave

    # Communication
    # discord
    vesktop
    element-desktop
    # Need to add Matrix.org stuff

    # File Management
    tumbler
    file-roller
    xarchiver
    p7zip

    # Images
    imv
    gimp

    # Audio
    pavucontrol
    playerctl
    ncspot
    cava

    # video
    mpv

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
