#!/usr/bin/env bash

set -u

gpu_device=
for candidate in /sys/class/drm/card*/device; do
    if [[ -r "$candidate/gpu_busy_percent" && -r "$candidate/mem_info_vram_used" ]]; then
        gpu_device=$candidate
        break
    fi
done
[[ -n "$gpu_device" ]] || exit 0

gpu_busy=$(<"$gpu_device/gpu_busy_percent")
vram_used=$(<"$gpu_device/mem_info_vram_used")
vram_gib=$(awk -v bytes="$vram_used" 'BEGIN { printf "%.1f", bytes / 1073741824 }')
printf '  %s%%  %sGiB \n' "$gpu_busy" "$vram_gib"
