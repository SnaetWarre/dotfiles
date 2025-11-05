#!/bin/bash

# Enable debug output
set -x

# --- Timing helpers ---
now_ms() { date +%s%3N; }
log_step() {
    local label="$1"; shift
    local start_ms="$1"; shift
    local end_ms; end_ms=$(now_ms)
    local delta=$((end_ms - start_ms))
    echo "[timing] ${label}: ${delta} ms"
}

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# If a specific wallpaper is provided as an argument, use it
if [ -n "$1" ]; then
    WALLPAPER="$1"
else
    # Otherwise, select a random wallpaper
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | shuf -n 1)
fi

echo "Selected wallpaper: $WALLPAPER"

# Apply wallpaper with pywal and wait for it to finish
# Use -q (quiet)
echo "Running Pywal to generate colors (waiting for completion)..."
# Default to the fast haishoku backend unless overridden
WAL_BACKEND="${WAL_BACKEND:-haishoku}"
__t0=$(now_ms)

# If the selected wallpaper differs from last colors.sh entry, force regeneration
PREV_WALL_FROM_COLORS=$(grep -E "^wallpaper='" "$HOME/.cache/wal/colors.sh" 2>/dev/null | sed -E "s/^wallpaper='(.*)'$/\1/")
if [ -n "$PREV_WALL_FROM_COLORS" ] && [ "$PREV_WALL_FROM_COLORS" != "$WALLPAPER" ]; then
    WAL_FORCE_REGEN=1
fi

# Optional hard force via env
if [ "${WAL_FORCE_REGEN:-0}" = "1" ]; then
    rm -f "$HOME/.cache/wal/colors.sh" "$HOME/.cache/wal/colors.json" 2>/dev/null || true
fi

# Start wallpaper transition immediately in parallel (doesn't depend on pywal)
__t3=$(now_ms)
swww img "$WALLPAPER" \
  --transition-type grow \
  --transition-angle 30 \
  --transition-duration 0 \
  --transition-fps 120 \
  --transition-bezier .2,1,.2,1 &
log_step "swww-start" "$__t3"

# Generate colors (blocking) — write full cache (no -n) so colors.{sh,json} are updated
wal --backend "$WAL_BACKEND" -i "$WALLPAPER" -q
# Ensure cache wallpaper path exists for consumers expecting it
printf '%s' "$WALLPAPER" > "$HOME/.cache/wal/wallpaper" 2>/dev/null || true
# Wait briefly for wal to write colors.sh; retry once without -n if missing
for _i in 1 2 3 4 5; do
    [ -f "$HOME/.cache/wal/colors.sh" ] && break
    sleep 0.05
done
if [ ! -f "$HOME/.cache/wal/colors.sh" ]; then
    wal --backend "$WAL_BACKEND" -i "$WALLPAPER" -q || true
    for _i in 1 2 3 4 5; do
        [ -f "$HOME/.cache/wal/colors.sh" ] && break
        sleep 0.05
    done
fi

# If still missing but colors.json exists, synthesize colors.sh from JSON
if [ ! -f "$HOME/.cache/wal/colors.sh" ] && [ -f "$HOME/.cache/wal/colors.json" ]; then
    /usr/bin/env python3 - <<'PY' > "$HOME/.cache/wal/colors.sh"
import json, os
p = os.path.expanduser('~/.cache/wal/colors.json')
with open(p) as f:
    data = json.load(f)
colors = data.get('colors', {})
wp = data.get('wallpaper', '')
print('# synthesized by wallpaper.sh from colors.json')
for i in range(16):
    k = f'color{i}'
    v = colors.get(k)
    if v is not None:
        print(f"{k}='{v}'")
if wp:
    print(f"wallpaper='{wp}'")
PY
    chmod 0644 "$HOME/.cache/wal/colors.sh" || true
fi
log_step "wal" "$__t0"
if [ $? -ne 0 ]; then
    echo "Error: wal command failed." >&2
    # Decide if you want to exit or continue with potentially old colors
    # exit 1
fi

# Removed pywalfox integration

# Apply colors using the new master script (handles Waybar, Rofi, etc.)
# This script sources the colors internally, ensuring it gets the latest.
echo "Applying Pywal colors via master script..."
if [ -x "$HOME/.config/hypr/scripts/apply_wal_outputs.sh" ]; then
    __t1=$(now_ms)
    "$HOME/.config/hypr/scripts/apply_wal_outputs.sh"
    log_step "apply_wal_outputs.sh" "$__t1"
else
    echo "Warning: Master script apply_wal_outputs.sh not found or not executable." >&2
fi

# Update wlogout colors (Still needs separate script for now)
echo "Updating wlogout colors..."
WLOGOUT_SCRIPT="$HOME/.config/wlogout/scripts/update-colors.sh"
if [ -x "$WLOGOUT_SCRIPT" ]; then
    __t2=$(now_ms)
    ( "$WLOGOUT_SCRIPT" >/dev/null 2>&1 ) &
    log_step "wlogout-colors-start" "$__t2"
else
    echo "Warning: wlogout update script not found or not executable: $WLOGOUT_SCRIPT" >&2
fi

# Rofi update is now handled by apply_wal_outputs.sh
# Set wallpaper with swww — smooth premium transition
# swww already started above; if needed we could wait here, but keep parallel for speed

# Reload Waybar to apply new colors
__t4=$(now_ms)
killall -SIGUSR2 waybar
log_step "waybar-reload" "$__t4"

# Total timing
log_step "TOTAL wallpaper.sh" "$__t0"

# Disable debug output
set +x

echo "Done!" 
