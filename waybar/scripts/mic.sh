#!/bin/bash
# ── mic.sh ─────────────────────────────────────────────────
# Description: Shows microphone mute/unmute status with icon
# Usage: Called by Waybar `custom/microphone` module every 1s
# Dependencies: wpctl (PipeWire)
# ───────────────────────────────────────────────────────────


# Load pywal colors if available
if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    source "$HOME/.cache/wal/colors.sh"
    color_orange="${color3:-#fab387}"
    color_cyan="${color6:-#56b6c2}"
else
    # Fallback to dionysus colors
    color_orange="#fab387"
    color_cyan="#56b6c2"
fi

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
  # Muted → mic-off icon
  echo "<span foreground='$color_orange'>[  ]</span>"
else
  # Active → mic-on icon
  echo "<span foreground='$color_cyan'>[  ]</span>"
fi

