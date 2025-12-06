#!/bin/bash
# ── display-mode.sh ─────────────────────────────────────────────
# Description: Shows current display mode (mirror/extend) and detects if second screen is connected
# Usage: Waybar `custom/display-mode` module
# Dependencies: hyprctl, jq
# ────────────────────────────────────────────────────────────────

# Debug mode: set to 1 to always show (for testing), 0 to only show when 2+ monitors
DEBUG_MODE=1

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo '{"text":"","tooltip":"jq not installed"}'
    exit 0
fi

# Get monitor count
monitor_count=$(hyprctl monitors -j 2>/dev/null | jq -r 'length' 2>/dev/null || echo "1")

# For debugging: always show if DEBUG_MODE=1
# For production: only show when 2+ monitors
if [ "$monitor_count" -lt 2 ] && [ "$DEBUG_MODE" -eq 0 ]; then
    # No second screen, return empty (won't show in waybar)
    echo '{"text":"","tooltip":""}'
    exit 0
fi

# If debug mode and only one monitor, show placeholder
if [ "$monitor_count" -lt 2 ] && [ "$DEBUG_MODE" -eq 1 ]; then
    echo '{"text":"󰍺","tooltip":"Debug: Only 1 monitor detected","class":"extend"}'
    exit 0
fi

# Get monitor info
monitors=$(hyprctl monitors -j 2>/dev/null)

# Check if monitors are mirrored (same x,y position)
monitor1_x=$(echo "$monitors" | jq -r '.[0].x // 0')
monitor1_y=$(echo "$monitors" | jq -r '.[0].y // 0')
monitor2_x=$(echo "$monitors" | jq -r '.[1].x // 0')
monitor2_y=$(echo "$monitors" | jq -r '.[1].y // 0')

if [ "$monitor1_x" = "$monitor2_x" ] && [ "$monitor1_y" = "$monitor2_y" ]; then
    mode="mirror"
    icon="󰍹  "
    tooltip="Display Mode: Mirroring\nClick to switch to Extended"
else
    mode="extend"
    icon="󰍺  "
    tooltip="Display Mode: Extended\nClick to switch to Mirroring"
fi

# JSON output
echo "{\"text\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$mode\"}"

