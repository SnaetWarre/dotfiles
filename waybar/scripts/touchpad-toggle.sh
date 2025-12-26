#!/bin/bash
# ── touchpad-toggle.sh ───────────────────────────────────────
# Description: Toggle touchpad on/off using hyprctl
# Usage: Called by Waybar `custom/touchpad` on-click
# Dependencies: hyprctl
# ──────────────────────────────────────────────────────────

TOUCHPAD_NAME="asue120a:00-04f3:319b-touchpad"
STATE_FILE="/tmp/waybar-touchpad-state"

# Read current state (default to enabled)
if [ -f "$STATE_FILE" ]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
else
    CURRENT_STATE="1"
fi

if [ "$CURRENT_STATE" = "1" ]; then
    hyprctl keyword "device[$TOUCHPAD_NAME]:enabled 0"
    echo "0" > "$STATE_FILE"
    notify-send "Touchpad" "Disabled"
else
    hyprctl keyword "device[$TOUCHPAD_NAME]:enabled 1"
    echo "1" > "$STATE_FILE"
    notify-send "Touchpad" "Enabled"
fi

# Signal waybar to update
pkill -RTMIN+12 waybar
