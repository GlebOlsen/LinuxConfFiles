{ lib, pkgs, ... }:
let
  mod = "Mod4";
in
{
  home.packages = with pkgs; [
    grim
    slurp
    swappy
    wl-kbptr
    hyprpicker
    copyq
    gammastep
    swayidle
    playerctl
  ];

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    wrapperFeatures.gtk = true;

    config = {
      modifier = mod;
      terminal = "foot";
      menu = "fuzzel";
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      # Disable built-in bar — using ironbar
      bars = [ ];

      output = {
        "DP-1" = {
          bg = "/home/div/pics/wallpapers_safe/wallhaven-856dlk.png fill";
          mode = "3840x2160";
          pos = "3200 0";
          transform = "normal";
        };
        "DP-2" = {
          bg = "/home/div/pics/wallpapersS_safe/245085.jpg fill";
          mode = "1280x1024";
          pos = "1920 1136";
          transform = "normal";
        };
        "HDMI-A-1" = {
          bg = "/home/div/pics/wallpapersV_safe/961f3a2ce5d5412a4dbdb30374543a74ba6f2f70.png fill";
          mode = "1920x1080";
          pos = "7040 240";
          transform = "270";
        };
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "dk";
        };
      };

      seat = {
        "seat0" = {
          cursor = "set Bibata-Original-Ice 24";
          xcursor_theme = "Bibata-Original-Ice 24";
        };
      };

      gaps = {
        inner = 8;
      };

      window = {
        border = 4;
        titlebar = false;
      };

      floating = {
        border = 4;
        titlebar = false;
      };

      colors = {
        focused = {
          border = "#b3ff00";
          background = "#b3ff00";
          text = "#051405";
          indicator = "#FF00FF";
          childBorder = "#b3ff00";
        };
        focusedInactive = {
          border = "#2d5a27";
          background = "#051405";
          text = "#a3be8c";
          indicator = "#2d5a27";
          childBorder = "#2d5a27";
        };
        unfocused = {
          border = "#132a13";
          background = "#051405";
          text = "#4f772d";
          indicator = "#132a13";
          childBorder = "#132a13";
        };
        urgent = {
          border = "#6a040f";
          background = "#6a040f";
          text = "#ffffff";
          indicator = "#FF00FF";
          childBorder = "#6a040f";
        };
      };

      workspaceOutputAssign = [
        { workspace = "1"; output = "DP-2"; }
        { workspace = "2"; output = "DP-1"; }
        { workspace = "3"; output = "HDMI-A-1"; }
      ];

      keybindings = lib.mkOptionDefault {
        # Swap kill to $mod+q (remove default $mod+Shift+q)
        "${mod}+q" = "kill";
        "${mod}+Shift+q" = null;

        # Extra bindings
        "${mod}+Shift+d" = "exec fuzzel --list-executables-in-path";
        "${mod}+Alt+v" = "exec copyq toggle";
        "${mod}+p" = "exec hyprpicker -a";
        "${mod}+Shift+o" = "exec swaylock -C ~/.config/swaylock/config";
        "${mod}+g" = "exec wl-kbptr";
        "Print" = "exec grim -g \"$(slurp)\" - | swappy -f -";
      };

      startup = [
        { command = "ironbar"; }
        { command = "copyq"; }
        { command = "gammastep -l 55.7:12.6 -t 6500:2700 -g 0.8 -m wayland"; }
        {
          command = "swayidle -w timeout 900 'swaylock -C ~/.config/swaylock/config' timeout 930 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on\"' before-sleep 'swaylock -C ~/.config/swaylock/config'";
        }
      ];
    };

    extraConfig = ''
      # Media keys — work even when screen is locked
      bindsym --locked XF86AudioMute exec pactl set-sink-mute \@DEFAULT_SINK@ toggle
      bindsym --locked XF86AudioLowerVolume exec pactl set-sink-volume \@DEFAULT_SINK@ -2%
      bindsym --locked XF86AudioRaiseVolume exec pactl set-sink-volume \@DEFAULT_SINK@ +2%
      bindsym --locked XF86AudioMicMute exec pactl set-source-mute \@DEFAULT_SOURCE@ toggle
      bindsym --locked XF86AudioPlay exec playerctl play-pause
      bindsym --locked XF86AudioNext exec playerctl next
      bindsym --locked XF86AudioPrev exec playerctl previous

      include /etc/sway/config.d/*
    '';
  };
}
