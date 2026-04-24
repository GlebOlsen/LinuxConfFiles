{ config, pkgs, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [ "https://cache.garnix.io" ];
  nix.settings.trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];

  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  # Bootloader set per-host (systemd-boot vs grub).
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  boot.kernelParams = [ "ipv6.disable=1" ];
  boot.supportedFilesystems = [ "ntfs" ];

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
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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

  programs.dconf.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
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

  users.users.div = {
    isNormalUser = true;
    description = "div";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "input" "video" "audio" "render" ];
  };
  programs.fish.enable = true;

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
    git
    yazi
    tmux
    fish
    mako
    lazygit
    fastfetch
    btop
    croc
    linuxPackages.cpupower
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
    vscode-fhs
    claude-code
    meld

    # Internet
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium
    tailscale
    mullvad

    # Communication
    vesktop
    element-desktop

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

    # Video
    mpv

    # Theming
    font-manager
    arc-theme
    iconpack-obsidian
    nwg-look
    bibata-cursors
  ];

  system.stateVersion = "25.11";
}
