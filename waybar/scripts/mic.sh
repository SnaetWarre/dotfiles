#!/bin/bash
# ── mic.sh ─────────────────────────────────────────────────
# Description: Shows microphone mute/unmute status with icon
# Usage: Called by Waybar `custom/microphone` module every 1s
# Dependencies: wpctl (PipeWire)
# ───────────────────────────────────────────────────────────

# Fast color cache (updated only if colors file changed)
CACHE_FILE="$HOME/.cache/wal/waybar_mic_colors_cache"
COLORS_FILE="$HOME/.cache/wal/colors"

if [ -f "$COLORS_FILE" ] && [ "$COLORS_FILE" -nt "$CACHE_FILE" ] 2>/dev/null; then
    # Extract colors directly (lines 4 and 7 for color3, color6)
    color_orange=$(sed -n '4p' "$COLORS_FILE" 2>/dev/null | sed 's/^#*#/#/')
    color_cyan=$(sed -n '7p' "$COLORS_FILE" 2>/dev/null | sed 's/^#*#/#/')
    [ -z "$color_orange" ] && color_orange="#fab387"
    [ -z "$color_cyan" ] && color_cyan="#56b6c2"
    echo "$color_orange|$color_cyan" > "$CACHE_FILE" 2>/dev/null
elif [ -f "$CACHE_FILE" ]; then
    IFS='|' read -r color_orange color_cyan < "$CACHE_FILE" 2>/dev/null
    [ -z "$color_orange" ] && color_orange="#fab387"
    [ -z "$color_cyan" ] && color_cyan="#56b6c2"
else
    color_orange="#fab387"
    color_cyan="#56b6c2"
fi

# Fast mute check - single wpctl call
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
  # Muted → mic-off icon
  echo "<span foreground='$color_orange'>[  ]</span>"
else
  # Active → mic-on icon
  echo "<span foreground='$color_cyan'>[  ]</span>"
fi

