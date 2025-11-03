#!/bin/bash
# workspace-2.sh — highlight workspace 2 if active

# Load pywal colors if available
if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    source "$HOME/.cache/wal/colors.sh"
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
