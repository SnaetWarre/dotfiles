#!/bin/bash
# ── battery.sh ─────────────────────────────────────────────
# Description: Shows battery % with ASCII bar + dynamic tooltip
# Usage: Waybar `custom/battery` every 10s
# Dependencies: upower, awk
#  ──────────────────────────────────────────────────────────

capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

# Cache upower calls (refresh every 30 seconds)
upower_cache="$HOME/.cache/wal/waybar_battery_upower_cache"
cache_age=0
if [ -f "$upower_cache" ]; then
    cache_time=$(stat -c %Y "$upower_cache" 2>/dev/null || echo 0)
    current_time=$(date +%s 2>/dev/null || echo 0)
    cache_age=$((current_time - cache_time))
fi

if [ ! -f "$upower_cache" ] || [ "$cache_age" -gt 30 ]; then
    time_to_empty=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | awk -F: '/time to empty/ {print $2}' | xargs)
    time_to_full=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | awk -F: '/time to full/ {print $2}' | xargs)
    echo "$time_to_empty|$time_to_full" > "$upower_cache" 2>/dev/null
else
    IFS='|' read -r time_to_empty time_to_full < "$upower_cache" 2>/dev/null
fi

# Icons
charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
default_icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)

index=$((capacity / 10))
[ $index -ge 10 ] && index=9

if [[ "$status" == "Charging" ]]; then
    icon=${charging_icons[$index]}
elif [[ "$status" == "Full" ]]; then
    icon="󰂅"
else
    icon=${default_icons[$index]}
fi

# Fast ASCII bar generation
filled=$((capacity / 10))
[ "$filled" -gt 10 ] && filled=10
empty=$((10 - filled))
bar=""
pad=""
i=0
while [ $i -lt $filled ]; do bar="${bar}█"; i=$((i+1)); done
i=0
while [ $i -lt $empty ]; do pad="${pad}░"; i=$((i+1)); done
ascii_bar="[$bar$pad]"

# Fast color cache (updated only if colors file changed)
CACHE_FILE="$HOME/.cache/wal/waybar_battery_colors_cache"
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

# Color thresholds
if [ "$capacity" -lt 20 ]; then
    fg="$color_red"
elif [ "$capacity" -lt 55 ]; then
    fg="$color_orange"
else
    fg="$color_cyan"
fi

# Build tooltip
if [[ "$status" == "Charging" ]]; then
    tooltip="Battery: $capacity% (Charging)\nTime to full: ${time_to_full:-Unknown}"
elif [[ "$status" == "Full" ]]; then
    tooltip="Battery: $capacity% (Full)"
else
    tooltip="Battery: $capacity%\nTime remaining: ${time_to_empty:-Unknown}"
fi

# JSON output
echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $capacity%</span>\",\"tooltip\":\"$tooltip\"}"
