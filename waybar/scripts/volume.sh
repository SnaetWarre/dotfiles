#!/bin/bash
# ── volume.sh ─────────────────────────────────────────────
# Description: Shows current audio volume percentage (minimal)
# Usage: Waybar `custom/volume` every 1s
# Dependencies: wpctl, awk
# ───────────────────────────────────────────────────────────

# Fast color cache (updated only if colors file changed)
CACHE_FILE="$HOME/.cache/wal/waybar_volume_colors_cache"
COLORS_FILE="$HOME/.cache/wal/colors"

if [ -f "$COLORS_FILE" ] && [ "$COLORS_FILE" -nt "$CACHE_FILE" ] 2>/dev/null; then
    # Extract colors directly (lines 2, 4, 7 for color1, color3, color6)
    color_red=$(sed -n '2p' "$COLORS_FILE" 2>/dev/null | sed 's/^#*#/#/')
    color_orange=$(sed -n '4p' "$COLORS_FILE" 2>/dev/null | sed 's/^#*#/#/')
    color_cyan=$(sed -n '7p' "$COLORS_FILE" 2>/dev/null | sed 's/^#*#/#/')
    [ -z "$color_red" ] && color_red="#bf616a"
    [ -z "$color_orange" ] && color_orange="#fab387"
    [ -z "$color_cyan" ] && color_cyan="#56b6c2"
    echo "$color_red|$color_orange|$color_cyan" > "$CACHE_FILE" 2>/dev/null
elif [ -f "$CACHE_FILE" ]; then
    IFS='|' read -r color_red color_orange color_cyan < "$CACHE_FILE" 2>/dev/null
    [ -z "$color_red" ] && color_red="#bf616a"
    [ -z "$color_orange" ] && color_orange="#fab387"
    [ -z "$color_cyan" ] && color_cyan="#56b6c2"
else
    color_red="#bf616a"
    color_orange="#fab387"
    color_cyan="#56b6c2"
fi

# Single wpctl call - get volume and check mute in one go
vol_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)

# Fast parsing: extract volume and mute status
if echo "$vol_output" | grep -q "MUTED"; then
    is_muted=true
    vol_int=0
else
    is_muted=false
    # Extract volume number directly (format: "Volume: 0.XX" or "Volume: 1.00")
    vol_raw=$(echo "$vol_output" | awk '{print $2}')
    # Convert to integer percentage (0-100)
    vol_int=$(awk -v v="$vol_raw" 'BEGIN {printf "%.0f", v*100}')
fi

# Get sink name (cached, refresh every 30 seconds to avoid stale data)
sink_cache="$HOME/.cache/wal/waybar_sink_cache"
cache_age=0
if [ -f "$sink_cache" ]; then
    cache_time=$(stat -c %Y "$sink_cache" 2>/dev/null || echo 0)
    current_time=$(date +%s 2>/dev/null || echo 0)
    cache_age=$((current_time - cache_time))
fi

if [ ! -f "$sink_cache" ] || [ "$cache_age" -gt 30 ]; then
    sink=$(wpctl status 2>/dev/null | awk '/Sinks:/,/Sources:/ {if (/\*/) {gsub(/^[│ ]*\*[ ]*[0-9]+\. /, ""); sub(/ \[vol:.*/, ""); gsub(/^[[:space:]]+/, ""); print; exit}}')
    [ -z "$sink" ] && sink="Default"
    echo "$sink" > "$sink_cache" 2>/dev/null
else
    sink=$(cat "$sink_cache" 2>/dev/null)
    [ -z "$sink" ] && sink="Default"
fi

# Icon logic
if [ "$is_muted" = true ]; then
  icon="󰖁"
elif [ "$vol_int" -eq 0 ]; then
  icon="󰕿"
elif [ "$vol_int" -lt 50 ]; then
  icon="󰖀"
else
  icon="󰕾"
fi

# Color logic
if [ "$is_muted" = true ] || [ "$vol_int" -lt 10 ]; then
  fg="$color_red"
elif [ "$vol_int" -lt 50 ]; then
  fg="$color_orange"
else
  fg="$color_cyan"
fi

# Tooltip text
if [ "$is_muted" = true ]; then
  tooltip="Audio: Muted\nOutput: $sink"
else
  tooltip="Audio: $vol_int%\nOutput: $sink"
fi

# Final JSON output
echo "{\"text\":\"<span foreground='$fg'>$icon $vol_int%</span>\",\"tooltip\":\"$tooltip\"}"
