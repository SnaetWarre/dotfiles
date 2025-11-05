#!/bin/bash
# workspace-2.sh — highlight workspace 2 if active

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
    color_orange="${color3:-#fab387}"
else
    # Fallback to dionysus color
    color_orange="#fab387"
fi

active=$(hyprctl activeworkspace -j | jq '.id')

if [ "$active" -eq 2 ]; then
  echo "[<span foreground='$color_orange'>●</span>]"
else
  echo "[Б]"
fi
