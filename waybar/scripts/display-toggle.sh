#!/bin/bash
# ── display-toggle.sh ─────────────────────────────────────────────
# Description: Toggle between mirroring and extending displays
# Usage: Waybar `custom/display-mode` on-click
# Dependencies: hyprctl, jq
# ────────────────────────────────────────────────────────────────

# Check if jq is available
if ! command -v jq &> /dev/null; then
    notify-send "Display Toggle" "jq is required but not installed" -t 3000
    exit 1
fi

# Get monitor info
monitors=$(hyprctl monitors -j 2>/dev/null)

# Check if we have at least 2 monitors
monitor_count=$(echo "$monitors" | jq -r 'length' 2>/dev/null || echo "1")
if [ "$monitor_count" -lt 2 ]; then
    notify-send "Display Toggle" "No second screen detected" -t 2000
    exit 0
fi

# Get monitor details
monitor1_name=$(echo "$monitors" | jq -r '.[0].name // ""')
monitor2_name=$(echo "$monitors" | jq -r '.[1].name // ""')
monitor1_res=$(echo "$monitors" | jq -r '.[0].width // 1920')x$(echo "$monitors" | jq -r '.[0].height // 1080')
monitor2_res=$(echo "$monitors" | jq -r '.[1].width // 1920')x$(echo "$monitors" | jq -r '.[1].height // 1080')

# Get current positions
monitor1_x=$(echo "$monitors" | jq -r '.[0].x // 0')
monitor1_y=$(echo "$monitors" | jq -r '.[0].y // 0')
monitor2_x=$(echo "$monitors" | jq -r '.[1].x // 0')
monitor2_y=$(echo "$monitors" | jq -r '.[1].y // 0')

# Determine current mode and toggle
if [ "$monitor1_x" = "$monitor2_x" ] && [ "$monitor1_y" = "$monitor2_y" ]; then
    # Currently mirroring, switch to extending
    # Position second monitor to the right of first
    monitor1_width=$(echo "$monitors" | jq -r '.[0].width // 1920')
    
    hyprctl keyword monitor "$monitor1_name,$monitor1_res,0x0,1" 2>/dev/null
    hyprctl keyword monitor "$monitor2_name,$monitor2_res,${monitor1_width}x0,1" 2>/dev/null
    
    notify-send "Display Mode" "Switched to Extended" -t 2000
else
    # Currently extending, switch to mirroring
    # Position both monitors at same coordinates
    hyprctl keyword monitor "$monitor1_name,$monitor1_res,0x0,1" 2>/dev/null
    hyprctl keyword monitor "$monitor2_name,$monitor2_res,0x0,1" 2>/dev/null
    
    notify-send "Display Mode" "Switched to Mirroring" -t 2000
fi

# Refresh waybar (you may need to adjust the signal number)
pkill -RTMIN+11 waybar 2>/dev/null || true

