#!/bin/bash
# ── battery.sh ─────────────────────────────────────────────
# Description: Shows battery % with ASCII bar + dynamic tooltip
# Usage: Waybar `custom/battery` every 10s
# Dependencies: upower, awk, seq, printf
#  ──────────────────────────────────────────────────────────

capacity=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)

# Get detailed info from upower
time_to_empty=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk -F: '/time to empty/ {print $2}' | xargs)
time_to_full=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk -F: '/time to full/ {print $2}' | xargs)

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

# ASCII bar
filled=$((capacity / 10))
empty=$((10 - filled))
bar=$(printf '█%.0s' $(seq 1 $filled))
pad=$(printf '░%.0s' $(seq 1 $empty))
ascii_bar="[$bar$pad]"

# Load pywal colors if available
if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    source "$HOME/.cache/wal/colors.sh"
    color_red="${color1:-#bf616a}"
    color_orange="${color3:-#fab387}"
    color_cyan="${color6:-#56b6c2}"
else
    # Fallback to dionysus colors
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
