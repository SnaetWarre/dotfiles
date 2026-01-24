#!/bin/bash
# ── kbd-brightness.sh ───────────────────────────────────────
# Description: Display current keyboard backlight brightness
# Usage: Called by Waybar `custom/kbd-brightness`
# Dependencies: asusctl
# ──────────────────────────────────────────────────────────

# Load wal/pywal colors from colors file
if [ -f "$HOME/.cache/wal/colors" ]; then
    color_index=0
    while IFS= read -r color || [ -n "$color" ]; do
        color="${color#\#}"
        color="#${color}"
        eval "color${color_index}=${color}"
        color_index=$((color_index + 1))
        [ $color_index -ge 16 ] && break
    done < "$HOME/.cache/wal/colors"
    color_off="${color8:-#6c7086}"
    color_low="${color4:-#89b4fa}"
    color_med="${color5:-#cba6f7}"
    color_high="${color6:-#f9e2af}"
else
    # Fallback colors
    color_off="#6c7086"
    color_low="#89b4fa"
    color_med="#cba6f7"
    color_high="#f9e2af"
fi

# Get current brightness from asusctl
brightness=$(asusctl leds get | awk -F': ' '{print $2}')

# Map brightness value to label and color
case "$brightness" in
    Off)
        text="󰌌 OFF"
        fg="$color_off"
        tooltip="Keyboard Backlight: Off"
        ;;
    Low)
        text="󰌌 LOW"
        fg="$color_low"
        tooltip="Keyboard Backlight: Low"
        ;;
    Med)
        text="󰌌 MED"
        fg="$color_med"
        tooltip="Keyboard Backlight: Medium"
        ;;
    High)
        text="󰌌 HIGH"
        fg="$color_high"
        tooltip="Keyboard Backlight: High"
        ;;
    *)
        text="󰌌 ??"
        fg="$color_off"
        tooltip="Keyboard Backlight: Unknown"
        ;;
esac

# Output JSON for waybar
echo "{\"text\": \"<span foreground='$fg'>$text</span>\", \"tooltip\": \"$tooltip\"}"
