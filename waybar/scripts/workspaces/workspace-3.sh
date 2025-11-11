#!/bin/bash
# workspace-3.sh — highlight workspace 3 if active

# Fast color cache (updated only if colors file changed)
CACHE_FILE="$HOME/.cache/wal/waybar_colors_cache"
COLORS_FILE="$HOME/.cache/wal/colors"

if [ -f "$COLORS_FILE" ] && [ "$COLORS_FILE" -nt "$CACHE_FILE" ] 2>/dev/null; then
    # Extract color3 directly (4th line, 0-indexed)
    color_orange=$(sed -n '4p' "$COLORS_FILE" 2>/dev/null | sed 's/^#*#/#/')
    [ -z "$color_orange" ] && color_orange="#fab387"
    echo "$color_orange" > "$CACHE_FILE" 2>/dev/null
elif [ -f "$CACHE_FILE" ]; then
    color_orange=$(cat "$CACHE_FILE" 2>/dev/null)
    [ -z "$color_orange" ] && color_orange="#fab387"
else
    color_orange="#fab387"
fi

# Fast JSON parsing without jq - extract id directly using sed
active=$(hyprctl activeworkspace -j 2>/dev/null | sed -n 's/.*"id":\s*\([0-9]*\).*/\1/p' | head -n1)
active=${active:-0}

if [ "$active" -eq 3 ]; then
  echo "[<span foreground='$color_orange'>●</span>]"
else
  echo "[В]"
fi
