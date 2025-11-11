#!/bin/bash
# ── brightness.sh ─────────────────────────────────────────
# Description: Shows current brightness with ASCII bar + tooltip
# Usage: Waybar `custom/brightness` every 2s
# Dependencies: brightnessctl, awk
#  ─────────────────────────────────────────────────────────

# Get brightness percentage
brightness=$(brightnessctl get 2>/dev/null || echo 0)
max_brightness=$(brightnessctl max 2>/dev/null || echo 1)
percent=$((brightness * 100 / max_brightness))

# Fast color cache (updated only if colors file changed)
CACHE_FILE="$HOME/.cache/wal/waybar_brightness_colors_cache"
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

# Fast ASCII bar generation
filled=$((percent / 10))
[ "$filled" -gt 10 ] && filled=10
empty=$((10 - filled))
bar=""
pad=""
i=0
while [ $i -lt $filled ]; do bar="${bar}█"; i=$((i+1)); done
i=0
while [ $i -lt $empty ]; do pad="${pad}░"; i=$((i+1)); done
ascii_bar="[$bar$pad]"

# Icon
icon="󰛨"

# Color thresholds
if [ "$percent" -lt 20 ]; then
    fg="$color_red"
elif [ "$percent" -lt 55 ]; then
    fg="$color_orange"
else
    fg="$color_cyan"
fi

# Device name (cached, refresh every 60 seconds)
device_cache="$HOME/.cache/wal/waybar_brightness_device_cache"
cache_age=0
if [ -f "$device_cache" ]; then
    cache_time=$(stat -c %Y "$device_cache" 2>/dev/null || echo 0)
    current_time=$(date +%s 2>/dev/null || echo 0)
    cache_age=$((current_time - cache_time))
fi

if [ ! -f "$device_cache" ] || [ "$cache_age" -gt 60 ]; then
    device=$(brightnessctl --machine-readable 2>/dev/null | awk -F, 'NR==1 {print $1}')
    [ -z "$device" ] && device="Display"
    echo "$device" > "$device_cache" 2>/dev/null
else
    device=$(cat "$device_cache" 2>/dev/null)
    [ -z "$device" ] && device="Display"
fi

# Tooltip text
tooltip="Brightness: $percent%\nDevice: $device"

# JSON output
echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $percent%</span>\",\"tooltip\":\"$tooltip\"}"
