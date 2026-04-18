#!/bin/sh
metadata="$(playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null || true)"

if [ -z "$metadata" ]; then
  exit 0
fi

if [ "${#metadata}" -gt 40 ]; then
  metadata="${metadata:0:37}..."
fi

printf '🎵 %s\n' "$metadata"
