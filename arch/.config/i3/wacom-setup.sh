#!/bin/sh
# Wacom Intuos Pro L (PTH-860): pen on the 4K screen, tablet cropped to 16:9 (top/bottom unused)
for d in "Wacom Intuos Pro L Pen stylus" "Wacom Intuos Pro L Pen eraser"; do
  xsetwacom set "$d" MapToOutput DisplayPort-0
  xsetwacom set "$d" Area 0 4106 62200 39094
done
# Finger touch at half speed
xinput set-prop "Wacom Intuos Pro L Finger touch" "Device Accel Constant Deceleration" 2
