#!/bin/bash
# ── asus-profile.sh ───────────────────────────────────────  
# Description: Display current ASUS power profile with color
# Usage: Called by Waybar `custom/asus-profile`
# Dependencies: asusctl, awk
# ──────────────────────────────────────────────────────────  

# Load pywal colors if available
if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    source "$HOME/.cache/wal/colors.sh"
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
    text="RAZGON"
    fg="$color_red"
    ;;
  Balanced)
    text="STABILIZATION"
    fg="$color_orange"
    ;;
  Quiet|LowPower)
    text="REACTOR SLEEP"
    fg="$color_cyan"
    ;;
  *)
    text="ASUS ??"
    fg="$color_fg"
    ;;
esac

echo "<span foreground='$fg'>$text</span>"
