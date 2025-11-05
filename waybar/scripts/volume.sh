#!/bin/bash
# ── volume.sh ─────────────────────────────────────────────
# Description: Shows current audio volume with ASCII bar + tooltip
# Usage: Waybar `custom/volume` every 1s
# Dependencies: wpctl, awk, seq, printf
# ───────────────────────────────────────────────────────────

# Get raw volume and convert to int
vol_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol_raw=$(echo "$vol_output" | awk '{ print $2 }' | sed 's/^Volume: //')
# Remove % sign if present and convert to percentage
vol_int=$(echo "$vol_raw" | awk '{ printf "%.0f", $1 * 100 }')

# Check mute status
is_muted=$(echo "$vol_output" | grep -q MUTED && echo true || echo false)

# Get default sink description (human-readable)
sink=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep '\*' | cut -d'.' -f2- | sed 's/^\s*//; s/\[.*//')

# Icon logic
if [ "$is_muted" = true ]; then
  icon="󰖁"
  vol_int=0
elif [ "$vol_int" -eq 0 ]; then
  icon="󰕿"
elif [ "$vol_int" -lt 50 ]; then
  icon="󰖀"
else
  icon="󰕾"
fi

# ASCII bar
filled=$((vol_int / 10))
empty=$((10 - filled))
bar=$(printf '█%.0s' $(seq 1 $filled))
pad=$(printf '░%.0s' $(seq 1 $empty))
ascii_bar="[$bar$pad]"

# Load wal/pywal colors from colors file
if [ -f "$HOME/.cache/wal/colors" ]; then
    # Read colors file (16 colors, indexed 0-15)
    color_index=0
    while IFS= read -r color || [ -n "$color" ]; do
        color="${color#\#}"
        color="#${color}"
        eval "color${color_index}=${color}"
        color_index=$((color_index + 1))
        [ $color_index -ge 16 ] && break
    done < "$HOME/.cache/wal/colors"
    color_red="${color1:-#bf616a}"
    color_orange="${color3:-#fab387}"
    color_cyan="${color6:-#56b6c2}"
else
    # Fallback to dionysus colors
    color_red="#bf616a"
    color_orange="#fab387"
    color_cyan="#56b6c2"
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
echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $vol_int%</span>\",\"tooltip\":\"$tooltip\"}"
