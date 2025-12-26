#!/bin/bash
# ── touchpad.sh ───────────────────────────────────────
# Description: Display current touchpad status
# Usage: Called by Waybar `custom/touchpad`
# Dependencies: none (uses state file)
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
    color_on="${color4:-#89b4fa}"
else
    # Fallback colors
    color_off="#6c7086"
    color_on="#89b4fa"
fi

STATE_FILE="/tmp/waybar-touchpad-state"

# Read current state (default to enabled)
if [ -f "$STATE_FILE" ]; then
    ENABLED=$(cat "$STATE_FILE")
else
    ENABLED="1"
fi

if [ "$ENABLED" = "1" ]; then
    text="󰇽 ON"
    fg="$color_on"
    tooltip="Touchpad: Enabled - Click to disable"
else
    text="󰇽 OFF"
    fg="$color_off"
    tooltip="Touchpad: Disabled - Click to enable"
fi

# Output JSON for waybar
echo "{\"text\": \"<span foreground='$fg'>$text</span>\", \"tooltip\": \"$tooltip\"}"
