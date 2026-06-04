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
  imports = [ ./clipboard.nix ];

  # Nix
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
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;
  };
  nix.optimise.automatic = true;
  programs.nh = {
    enable = true;
    flake = flakeDir;
  };
  programs.nix-ld.enable = true;

  # Boot & kernel
  # Bootloader set per-host (systemd-boot vs grub).
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_latest;
  boot.kernelParams = [
    # Latency
    "threadirqs"
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
  boot.tmp.cleanOnBoot = true;
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "kernel.printk" = "3 3 3 3";
  };
  zramSwap.enable = true;

  # Network
  networking.networkmanager.enable = true;
  networking.getaddrinfo.precedence = {
    "::1/128" = 50;
    "::/0" = 40;
    "2002::/16" = 30;
    "::/96" = 20;
    # Prefer IPv4-mapped addresses while keeping IPv6 available.
    "::ffff:0:0/96" = 100;
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

  # Locale, keyboard & time
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "dk";
    variant = "winkeys";
  };
  console.keyMap = "dk-latin1";

  # Audio (PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Desktop — Sway / Wayland
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  programs.dconf.enable = true;
  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    XCURSOR_THEME = "miniature";
    XCURSOR_SIZE = "64";
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "Cartograph CF" ];
    sansSerif = [ "Cartograph CF" ];
    serif = [ "Cartograph CF" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # Users
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "networkmanager" "input" "video" "audio" "render" ];
  };

  # Programs
  programs.git = {
    enable = true;
    config = {
      credential.helper = "store";
      init.defaultBranch = "main";
    };
  };
  programs.neovim = let
    tsParsers = pkgs.symlinkJoin {
      name = "nvim-treesitter-parsers";
      paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
    };
  in {
    enable = true;
    vimAlias = true;
    viAlias = true;
    withNodeJs = true;
    runtime = {
      "parser".source = "${tsParsers}/parser";
      "queries".source = "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries";
    };
  };

  # Thunar GUI file manager.
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.tumbler.enable = true; # thumbnail daemon for Thunar
  services.gvfs.enable = true;

  # Services & security
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;

  # Logging & docs
  services.journald.extraConfig = ''
    SystemMaxUse=20M
    MaxRetentionSec=3days
  '';
  documentation.enable = false;

  environment.systemPackages = with pkgs; [
    # System
    nix-tree
    # nix-output-monitor nix-update nix-init nix-melt nurl
    wl-kbptr
    nmap
    dysk
    wget
    tmux
    mako
    fastfetch
    btop
    croc
    config.boot.kernelPackages.cpupower
    lm_sensors
    jq
    fuzzel

    # Terminal
    foot

    # Sway
    waybar

    # Display
    wdisplays
    wpaperd
    gammastep

    # Clip/Screen/Extras
    # (wl-clipboard + cliphist live in ./clipboard.nix)
    grim
    slurp
    swappy
    hyprpicker

    # Neovim runtime deps (telescope, grug-far, blink-ripgrep)
    ripgrep
    fd

    # Editors
    meld
    lazygit

    # Vibes
    master.codex
    master.claude-code
    nodejs_26
    uv

    # Internet
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium
    tailscale
    # mullvad

    # Communication
    vesktop
    element-desktop

    # File Management
    p7zip
    file-roller # GUI archive manager (Thunar archive-plugin backend)
    xarchiver   # GUI archive manager

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
    matcha-gtk-theme
    iconpack-obsidian
    nwg-look

    # Local cursor theme
    (runCommandLocal "miniature-cursors" { } ''
      mkdir -p $out/share/icons/miniature
      cp -r ${../assets/cursors/miniature}/. $out/share/icons/miniature/
    '')
  ];

  system.stateVersion = "26.05";
}
