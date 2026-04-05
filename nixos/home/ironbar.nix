{ pkgs, ... }:
let
  jsonFormat = pkgs.formats.json { };

  gpuUsageScript = pkgs.writeShellScript "ironbar-gpu-usage" ''
    for gpu_busy in /sys/class/drm/card*/device/gpu_busy_percent; do
      if [ -r "$gpu_busy" ]; then
        value="$(${pkgs.coreutils}/bin/cat "$gpu_busy")"

        if [ -n "$value" ]; then
          printf '%s%%\n' "$value"
          exit 0
        fi
      fi
    done
    exit 0
  '';

  playerctlScript = pkgs.writeShellScript "ironbar-playerctl" ''
    metadata="$(${pkgs.playerctl}/bin/playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null || true)"

    if [ -z "$metadata" ]; then
      exit 0
    fi

    if [ "''${#metadata}" -gt 40 ]; then
      metadata="''${metadata:0:37}..."
    fi

    printf '🎵 %s\n' "$metadata"
  '';

  dp1Bar = {
    position = "top";
    height = 18;
    start = [
      {
        type = "workspaces";
        all_monitors = true;
        sort = "added";
      }
    ];
    center = [
      {
        type = "focused";
        icon_size = 16;
      }
      {
        type = "script";
        name = "playerctl";
        cmd = "${playerctlScript}";
        interval = 2000;
        show_if = "${pkgs.playerctl}/bin/playerctl status >/dev/null 2>&1";
        on_click_left = "${pkgs.playerctl}/bin/playerctl play-pause";
        on_scroll_up = "${pkgs.playerctl}/bin/playerctl next";
        on_scroll_down = "${pkgs.playerctl}/bin/playerctl previous";
      }
    ];
    end = [
      {
        type = "volume";
        format = "🔊 {percentage}%";
        mute_format = "🔇 muted";
      }
      {
        type = "sys_info";
        format = [
          "C: {cpu_percent}% 🔳"
          "{temp_c@k10temp:.0}°C"
          "M: {memory_used#Gi:.1} GiB 🟰"
          "G: {temp_c@amdgpu:.0}°C 🔲"
        ];
        interval = {
          cpu = 1;
          memory = 5;
          temps = 2;
        };
      }
      {
        type = "script";
        cmd = "${gpuUsageScript}";
        interval = 2000;
      }
      {
        type = "clock";
      }
      {
        type = "tray";
      }
    ];
  };

  ironbarConfig = {
    start = null;
    center = null;
    end = null;
    monitors = {
      "DP-1" = dp1Bar;
      "DP-2" = [ ];
      "HDMI-A-1" = [ ];
    };
  };
in
{
  xdg.configFile."ironbar/config.json".source = jsonFormat.generate "ironbar-config.json" ironbarConfig;

  xdg.configFile."ironbar/style.css".text = ''
    * {
      border-radius: 0;
      border: none;
      box-shadow: none;
      background-image: none;
      font-family: "Cartograph CF", monospace;
    }

    scale > trough {
      background-color: #2d2d2d;
    }

    scale > trough > highlight {
      background-color: #6699cc;
      border-style: solid;
      border-color: #6699cc;
      border-width: 0.2em;
    }

    scale > trough > slider {
      background-color: #fff;
    }

    switch > slider {
      background-color: #fff;
    }

    switch:checked {
      background-color: #6699cc;
    }

    switch:not(:checked) {
      background-color: #2d2d2d;
    }

    #bar,
    popover,
    popover contents,
    calendar {
      background-color: rgba(0, 26, 15, 0.73);
    }

    box,
    button,
    label {
      background-color: transparent;
      color: #fff;
      line-height: 16px;
    }

    button {
      padding-left: 0.5em;
      padding-right: 0.5em;
    }

    button:hover,
    button:active {
      background-color: rgba(179, 255, 0, 0.53);
    }

    #end > * + * {
      margin-left: 1em;
    }

    #center > * + * {
      margin-left: 1em;
    }

    .sysinfo > * + * {
      margin-left: 0.5em;
    }

    .clock {
      font-weight: bold;
    }

    #playerctl {
      color: #b3ff00;
    }

    .popup-clock .calendar-clock {
      font-size: 2em;
    }

    .popup-clock .calendar .today {
      background-color: #6699cc;
    }

    .workspaces .item.visible {
      box-shadow: none;
    }

    .workspaces .item.focused {
      box-shadow: none;
      background-color: #b3ff00;
      color: #000;
    }

    .workspaces .item.focused label,
    .workspaces .item.focused .text-icon {
      color: #000;
    }

    .workspaces .item:hover {
      background-color: rgba(179, 255, 0, 0.53);
    }

    .workspaces .item.urgent {
      background-color: #8f0a0a;
    }
  '';
}