#!/bin/sh
for gpu_busy in /sys/class/drm/card*/device/gpu_busy_percent; do
  if [ -r "$gpu_busy" ]; then
    value="$(cat "$gpu_busy")"

    if [ -n "$value" ]; then
      printf '%s%%\n' "$value"
      exit 0
    fi
  fi
done
exit 0
