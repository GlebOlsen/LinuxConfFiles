{ config, pkgs, lib, inputs, ... }:

let
  username = "div";
  flakeDir = "/home/${username}/repo/linuxconffiles/nixos";
  master = import inputs.nixpkgs-master {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    trusted-users = [ "@wheel" ];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Bootloader set per-host (systemd-boot vs grub).
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "ipv6.disable=1"
    # Latency
    "threadirqs"
    "transparent_hugepage=madvise"
    "mitigations=off"
    "nowatchdog"
    "split_lock_detect=off"
    "iommu=pt"
    # Quiet boot / less logging
    "quiet"
    "loglevel=3"
    "udev.log_level=3"
    "rd.udev.log_level=3"
    "systemd.show_status=auto"
  ];
  boot.consoleLogLevel = 3;
  boot.supportedFilesystems = [ "ntfs" ];

  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  documentation.enable = false;

  services.xserver.xkb = {
    layout = "dk";
    variant = "winkeys";
  };
  console.keyMap = "dk-latin1";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.dconf.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XCURSOR_THEME = "Bibata-Original-Ice";
    XCURSOR_SIZE = "24";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    nerd-fonts.fira-code
    noto-fonts-color-emoji
  ];

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "networkmanager" "input" "video" "audio" "render" ];
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
    flake = flakeDir;
  };

  programs.git = {
    enable = true;
    config = {
      credential.helper = "store";
      init.defaultBranch = "main";
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    withNodeJs = false;
  };

  programs.yazi = {
    enable = true;
    settings.yazi.mgr.show_hidden = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  environment.systemPackages = with pkgs; [
    # System
    wl-kbptr
    nmap
    dysk
    wget
    tmux
    fish
    mako
    lazygit
    fastfetch
    btop
    croc
    config.boot.kernelPackages.cpupower
    fuzzel

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

    # Neovim runtime deps (lazy.nvim + telescope + spectre + treesitter)
    ripgrep
    fd
    gcc
    gnumake
    tree-sitter

    # Editors
    # master.vscode-fhs
    helix
    micro
    master.claude-code
    master.codex
    meld

    # Internet
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium
    tailscale
    mullvad

    # Communication
    vesktop
    element-desktop

    # File Management
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

    # Video
    mpv

    # Theming
    font-manager
    arc-theme
    iconpack-obsidian
    nwg-look
    bibata-cursors
  ];

  system.stateVersion = "26.05";
}
