#!/bin/bash
# ── volume.sh ─────────────────────────────────────────────
# Description: Ultra-fast volume display for waybar
# Usage: Use with signal 10 for instant updates
# Config: "custom/volume": { "exec": "...", "signal": 10, "return-type": "json" }
# Trigger: pkill -RTMIN+10 waybar (after volume change)
# ───────────────────────────────────────────────────────────

# Get volume info in one call
vol_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)

# Check mute and extract volume
if [[ "$vol_output" == *"MUTED"* ]]; then
    vol=0
    icon="󰖁"
    muted=true
else
    muted=false
    # Extract the decimal (e.g., "0.52" from "Volume: 0.52")
    vol_raw=${vol_output#Volume: }
    vol_raw=${vol_raw%% *}
    # Convert to percentage
    vol=$(awk -v v="$vol_raw" 'BEGIN { printf "%.0f", v * 100 }')

    if (( vol == 0 )); then
        icon="󰕿"
    elif (( vol < 50 )); then
        icon="󰖀"
    else
        icon="󰕾"
    fi
fi

# Output JSON
if [[ "$muted" == true ]]; then
    printf '{"text":"%s %s%%","tooltip":"Muted","class":"muted"}\n' "$icon" "$vol"
else
    printf '{"text":"%s %s%%","tooltip":"Volume: %s%%","class":"vol%s"}\n' "$icon" "$vol" "$vol" "$(( (vol / 25) * 25 ))"
fi
