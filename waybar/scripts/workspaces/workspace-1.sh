#!/bin/bash
# workspace-1.sh — Show workspace 1 number, highlighted if active

# Fast color cache (updated only if colors file changed)
CACHE_FILE="$HOME/.cache/wal/waybar_colors_cache"
COLORS_FILE="$HOME/.cache/wal/colors"

if [ -f "$COLORS_FILE" ] && [ "$COLORS_FILE" -nt "$CACHE_FILE" ] 2>/dev/null; then
    # Extract color6 directly (7th line, 0-indexed)
    color_highlight=$(sed -n '7p' "$COLORS_FILE" 2>/dev/null | sed 's/^#*#/#/')
    [ -z "$color_highlight" ] && color_highlight="#fab387"
    echo "$color_highlight" > "$CACHE_FILE" 2>/dev/null
elif [ -f "$CACHE_FILE" ]; then
    color_highlight=$(cat "$CACHE_FILE" 2>/dev/null)
    [ -z "$color_highlight" ] && color_highlight="#fab387"
else
    color_highlight="#fab387"
fi

# Fast JSON parsing without jq - extract id directly using sed
active=$(hyprctl activeworkspace -j 2>/dev/null | sed -n 's/.*"id":\s*\([0-9]*\).*/\1/p' | head -n1)
active=${active:-0}

if [ "$active" -eq 1 ]; then
  echo "<span foreground='$color_highlight' weight='bold'>1</span>"
else
  echo "1"
fi
