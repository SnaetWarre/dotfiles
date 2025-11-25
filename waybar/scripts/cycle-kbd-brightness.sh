#!/bin/bash
# ── cycle-kbd-brightness.sh ───────────────────────────────────────
# Description: Cycle through keyboard backlight brightness levels
# Usage: Called by Waybar `custom/kbd-brightness` on-click
# Dependencies: asusctl
# ──────────────────────────────────────────────────────────

# Get current brightness from sysfs
brightness_file="/sys/class/leds/asus::kbd_backlight/brightness"
if [ -f "$brightness_file" ]; then
    current=$(cat "$brightness_file")
else
    current=0
fi

# Cycle through brightness levels: 0 (off) -> 1 (low) -> 2 (med) -> 3 (high) -> 0 (off)
case "$current" in
    0)
        asusctl -k low
        ;;
    1)
        asusctl -k med
        ;;
    2)
        asusctl -k high
        ;;
    3)
        asusctl -k off
        ;;
    *)
        # Default to off if unknown
        asusctl -k off
        ;;
esac
