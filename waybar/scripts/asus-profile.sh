#!/bin/bash
# ── asus-profile.sh ───────────────────────────────────────
# Description: Display current ASUS power profile with color
# Usage: Called by Waybar `custom/asus-profile`
# Dependencies: asusctl, awk
# ──────────────────────────────────────────────────────────

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
    color_fg="${color7:-#ffffff}"
else
    # Fallback to dionysus colors
    color_red="#bf616a"
    color_orange="#fab387"
    color_cyan="#56b6c2"
    color_fg="#ffffff"
fi

profile=$(asusctl profile -p | awk '/Active profile/ {print $NF}')

case "$profile" in
  Performance)
    text="REACTOR ON"
    fg="$color_red"
    ;;
  Balanced)
    text="STABILIZATION"
    fg="$color_orange"
    ;;
  Quiet|LowPower)
    text="REACTOR OFF"
    fg="$color_cyan"
    ;;
  *)
    text="ASUS ??"
    fg="$color_fg"
    ;;
esac

echo "<span foreground='$fg'>$text</span>"
