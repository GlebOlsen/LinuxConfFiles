#!/bin/bash
OUTPUT="LVDS-1"

# Detect current orientation
current=$(xrandr | grep "^$OUTPUT connected" | grep -oE '(normal|left|inverted|right)' | head -1)

case "$current" in
    normal)
        next="right";  matrix="0 1 0 -1 0 1 0 0 1"; w_rot="cw" ;;
    right)
        next="inverted"; matrix="-1 0 1 0 -1 1 0 0 1"; w_rot="half" ;;
    inverted)
        next="left";   matrix="0 -1 1 1 0 0 0 0 1"; w_rot="ccw" ;;
    *)
        next="normal"; matrix="1 0 0 0 1 0 0 0 1"; w_rot="none" ;;
esac

# 1. Rotate Screen
xrandr --output "$OUTPUT" --rotate "$next"

# 2. Rotate Touch (using ID 10)
xinput set-prop "10" "Coordinate Transformation Matrix" $matrix

# 3. Rotate Pen & Eraser (using IDs 15 & 16)
xsetwacom set "15" Rotate "$w_rot"
xsetwacom set "16" Rotate "$w_rot"

# 4. Clear Pen/Eraser matrix (prevents "double rotation" conflict)
xinput set-prop "15" "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
xinput set-prop "16" "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
