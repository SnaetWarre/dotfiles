#!/bin/bash

# Enable debug output only when requested
if [ "${WALLPAPER_DEBUG:-0}" = "1" ]; then
    set -x
fi

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
WAL_BIN="${WAL_BIN:-$HOME/.local/bin/wal}"
WAL_BACKEND="${WAL_BACKEND:-wal}"
WAL_SATURATE="${WAL_SATURATE:-}"
WAL_USED_NORMALIZED=0

run_wal() {
    local wal_input="$WALLPAPER"
    local normalized_image=""
    local wal_status=0
    local wal_args=()

    wal_args=("$WAL_BIN" -i "$wal_input" -q -W)
    if [ -n "$WAL_SATURATE" ]; then
        wal_args+=(--saturate "$WAL_SATURATE")
    fi
    if "${wal_args[@]}"; then
        return 0
    fi

    # Some otherwise displayable JPEGs contain truncated data that walrs
    # rejects. Normalize only the palette input and leave the wallpaper itself
    # untouched.
    if ! command -v magick >/dev/null 2>&1; then
        return 1
    fi

    normalized_image=$(mktemp --suffix=.png)
    echo "wal could not decode the wallpaper; retrying with a normalized palette image..." >&2
    if ! magick "$WALLPAPER" -auto-orient "$normalized_image"; then
        rm -f "$normalized_image"
        return 1
    fi

    wal_args=("$WAL_BIN" -i "$normalized_image" -q -W)
    if [ -n "$WAL_SATURATE" ]; then
        wal_args+=(--saturate "$WAL_SATURATE")
    fi
    "${wal_args[@]}" || wal_status=$?
    if [ "$wal_status" -eq 0 ]; then
        WAL_USED_NORMALIZED=1
    fi
    rm -f "$normalized_image"
    return "$wal_status"
}

# If a specific wallpaper is provided as an argument, use it
if [ -n "$1" ]; then
    WALLPAPER="$1"
else
    # Otherwise, select a random wallpaper
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | shuf -n 1)
fi

echo "Selected wallpaper: $WALLPAPER"

# Apply wallpaper and wait for palette generation to finish
# Use -q (quiet)
echo "Running wal to generate colors (waiting for completion)..."
# Use the fast native backend with a mild saturation boost unless overridden
__t0=$(now_ms)

if [ ! -x "$WAL_BIN" ]; then
    echo "Error: wal binary not found at $WAL_BIN" >&2
    exit 1
fi

# If the selected wallpaper differs from the last colors.sh entry, force
# regeneration. walrs has emitted both single- and double-quoted paths.
PREV_WALL_FROM_COLORS=$(grep -m1 -E "^wallpaper=" "$HOME/.cache/wal/colors.sh" 2>/dev/null || true)
PREV_WALL_FROM_COLORS=${PREV_WALL_FROM_COLORS#wallpaper=}
PREV_WALL_FROM_COLORS=${PREV_WALL_FROM_COLORS#\'}
PREV_WALL_FROM_COLORS=${PREV_WALL_FROM_COLORS%\'}
PREV_WALL_FROM_COLORS=${PREV_WALL_FROM_COLORS#\"}
PREV_WALL_FROM_COLORS=${PREV_WALL_FROM_COLORS%\"}
if [ -n "$PREV_WALL_FROM_COLORS" ] && [ "$PREV_WALL_FROM_COLORS" != "$WALLPAPER" ]; then
    WAL_FORCE_REGEN=1
fi

# Optional hard force via env
if [ "${WAL_FORCE_REGEN:-0}" = "1" ]; then
    rm -f "$HOME/.cache/wal/colors.sh" "$HOME/.cache/wal/colors.json" 2>/dev/null || true
fi

# Ensure awww-daemon is running
if ! pgrep -x "awww-daemon" > /dev/null; then
    echo "Starting awww-daemon..."
    awww-daemon &
    sleep 1
fi

# Start wallpaper transition immediately in parallel (doesn't depend on pywal)
__t3=$(now_ms)
awww img "$WALLPAPER" \
    --transition-type grow \
    --transition-angle 30 \
    --transition-duration 0.5 \
    --transition-fps 120 \
    --transition-bezier .2,1,.2,1 &
log_step "awww-start" "$__t3"

# Generate colors (blocking) with the local pywal-rs build
if ! run_wal; then
    echo "Error: wal could not generate a palette for $WALLPAPER." >&2
    exit 1
fi

# wal records its input path in the generated cache. When a normalized image
# was needed, replace that temporary path with the real wallpaper path before
# any theme consumer reads it.
if [ "$WAL_USED_NORMALIZED" = "1" ]; then
    WALLPAPER_PATH="$WALLPAPER" /usr/bin/env python3 - <<'PY'
import json
import os
from pathlib import Path

cache_dir = Path.home() / ".cache" / "wal"
wallpaper = os.environ["WALLPAPER_PATH"]
colors_sh = cache_dir / "colors.sh"
colors_json = cache_dir / "colors.json"

if colors_sh.exists():
    lines = colors_sh.read_text().splitlines()
    shell_quoted_wallpaper = wallpaper.replace("'", "'\"'\"'")
    replacement = f"wallpaper='{shell_quoted_wallpaper}'"
    lines = [
        replacement if line.startswith("wallpaper=") else line
        for line in lines
    ]
    colors_sh.write_text("\n".join(lines) + "\n")

if colors_json.exists():
    data = json.loads(colors_json.read_text())
    data["wallpaper"] = wallpaper
    colors_json.write_text(json.dumps(data, indent=4) + "\n")
PY
fi

# Ensure cache wallpaper path exists for consumers expecting it
printf '%s' "$WALLPAPER" > "$HOME/.cache/wal/wallpaper" 2>/dev/null || true
# Wait briefly for wal to write colors.sh; retry once without -n if missing
for _i in 1 2 3 4 5; do
    [ -f "$HOME/.cache/wal/colors.sh" ] && break
    sleep 0.05
done
if [ ! -f "$HOME/.cache/wal/colors.sh" ]; then
    run_wal || true
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

# Removed pywalfox integration

# Apply colors using the new master script (handles Waybar, Rofi, etc.)
# This script sources the colors internally, ensuring it gets the latest.
echo "Applying wal colors via master script..."
if [ -x "$HOME/.config/hypr/scripts/apply_wal_outputs.sh" ]; then
    __t1=$(now_ms)
    "$HOME/.config/hypr/scripts/apply_wal_outputs.sh"
    log_step "apply_wal_outputs.sh" "$__t1"
else
    echo "Warning: Master script apply_wal_outputs.sh not found or not executable." >&2
fi

# Rofi update is now handled by apply_wal_outputs.sh
# Set wallpaper with awww — smooth premium transition
# awww already started above; if needed we could wait here, but keep parallel for speed

# Waybar reload is handled inside apply_wal_outputs.sh when needed

# Total timing
log_step "TOTAL wallpaper.sh" "$__t0"

# Disable debug output
if [ "${WALLPAPER_DEBUG:-0}" = "1" ]; then
    set +x
fi

echo "Done!"
