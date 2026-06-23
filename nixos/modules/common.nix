{ config, pkgs, lib, inputs, ... }:

let
  username = "div";
  flakeDir = "/home/${username}/repo/linuxconffiles/nixos";
in
{
  imports = [
    ./clipboard.nix
    ./styling.nix
  ];

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
  nixpkgs.overlays = [
    # master nixpkgs exposed as pkgs.master
    (final: _prev: {
      master = import inputs.nixpkgs-master {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    })
    # sway fix fullscreen
    (final: prev: {
      sway-unwrapped = prev.sway-unwrapped.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (final.fetchpatch {
            url = "https://gist.githubusercontent.com/bim9262/0f63e6b5d8107d7d2654b61e0b7debe2/raw";
            hash = "sha256-+6II1Xnth/uenTeCnOUSDgsjpRgfW3ilRp+nMjs1eJg=";
          })
        ];
      });
      sway = prev.sway.override { inherit (final) sway-unwrapped; };
    })
  ];
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
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "kernel.printk" = "3 3 3 3";
  };
  zramSwap.enable = true;

  # Network
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
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Desktop — Wayland
  programs.sway = {
    enable = true;
    package = pkgs.sway;
    wrapperFeatures.gtk = true;
  };
  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # Users
  users.users.root.hashedPassword = "!";
  # sudo passwd -dl root (to remove the password and disable login)
  users.defaultUserShell = pkgs.fish;
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "input" "video" "audio" "render" ];
  };

  # Programs
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      set -g fish_prompt_pwd_dir_length 0
      fish_config theme choose seaweed
      set -g __fish_git_prompt_hide_untrackedfiles 0
      fish_config prompt choose informative_vcs
    '';
  };
  programs.git = {
    enable = true;
    config = {
      credential.helper = "store";
      init.defaultBranch = "main";
    };
  };
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showRandomTip = false;
        showCommandLog = false;
        showBottomLine = false;
        border = "bold";
        scrollHeight = 4;
        nerdFontsVersion = "3";
      };
      git.parseEmoji = true;
      os.editPreset = "helix";
      disableStartupPopups = true;
      update.method = "never";
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
  services.tumbler.enable = true; # Thunar thumbnails
  services.gvfs.enable = true;

  # Services & security
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.fstrim.enable = true;
  # services.fwupd.enable = true;
  # QMK keychron stuff
  # services.udev.extraRules = ''
  #   KERNEL=="hidraw*", ATTRS{idVendor}=="3434", MODE="0660", TAG+="uaccess"
  #   '';

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
    tree
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
    wooz

    # Mouse stuff
    wl-kbptr
    wlrctl

    # Terminal
    foot

    # Sway
    waybar

    # Display
    wdisplays
    gammastep

    # Clip/Screen/Extras
    # (wl-clipboard + cliphist live in ./clipboard.nix)
    grim
    slurp
    swappy
    hyprpicker

    # Coding
    meld
    scooter
    helix
    ripgrep
    fd

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
  ];

  system.stateVersion = "26.11";
}
