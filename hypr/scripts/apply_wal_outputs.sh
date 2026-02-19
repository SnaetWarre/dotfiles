#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Timing helpers ---
now_ms() { date +%s%3N; }
log_step() {
    local label="$1"; shift
    local start_ms="$1"; shift
    local end_ms; end_ms=$(now_ms)
    local delta=$((end_ms - start_ms))
    echo "[timing] ${label}: ${delta} ms"
}
__t_total=$(now_ms)

# Only write to target if content actually changed. Echoes "changed" or "unchanged" and returns 0/1 accordingly.
write_if_changed() {
    local tmp_file="$1"
    local target_file="$2"
    if [ -f "$target_file" ] && cmp -s "$tmp_file" "$target_file"; then
        rm -f "$tmp_file"
        echo "unchanged"
        return 1
    else
        mv "$tmp_file" "$target_file"
        echo "changed"
        return 0
    fi
}

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wal"
COLORS_SH="$CACHE_DIR/colors.sh"
COLORS_JSON="$CACHE_DIR/colors.json"
CONFIG_DIR="$HOME/.config"
LOCAL_SHARE_DIR="$HOME/.local/share"

WAYBAR_CONFIG_DIR="$CONFIG_DIR/waybar"
WAYBAR_TEMPLATE="$WAYBAR_CONFIG_DIR/style.css.template"
WAYBAR_OUTPUT_CSS="$WAYBAR_CONFIG_DIR/style.css"
WAYBAR_ICONS_DIR="$WAYBAR_CONFIG_DIR/icons"
PERPLEXITY_SVG="$WAYBAR_ICONS_DIR/perplexity.svg"

ROFI_CONFIG_DIR="$CONFIG_DIR/rofi"
ROFI_COLORS_RASI="$ROFI_CONFIG_DIR/colors.rasi"                 # For config.rasi
ROFI_WALLPAPER_TEMPLATE="$ROFI_CONFIG_DIR/wallpaper.rasi.template" # Wallpaper theme template
ROFI_WALLPAPER_OUTPUT="$ROFI_CONFIG_DIR/wallpaper.rasi"         # Wallpaper theme output

SWAYNC_CONFIG_DIR="$CONFIG_DIR/swaync"
SWAYNC_TEMPLATE="$SWAYNC_CONFIG_DIR/style.css.template"
SWAYNC_OUTPUT_CSS="$SWAYNC_CONFIG_DIR/style.css"

WLOGOUT_CONFIG_DIR="$CONFIG_DIR/wlogout"
WLOGOUT_TEMPLATE="$WLOGOUT_CONFIG_DIR/style.css.template"
WLOGOUT_OUTPUT_CSS="$WLOGOUT_CONFIG_DIR/style.css"
WLOGOUT_ICONS_DIR="$WLOGOUT_CONFIG_DIR/icons"
WLOGOUT_ASSETS_DIR="/usr/share/wlogout/assets" # Source for original icons

SWAYLOCK_CONFIG_DIR="$CONFIG_DIR/swaylock"
SWAYLOCK_TEMPLATE="$SWAYLOCK_CONFIG_DIR/config.template"
SWAYLOCK_OUTPUT_CONFIG="$SWAYLOCK_CONFIG_DIR/config"

GHOSTTY_CONFIG_DIR="$CONFIG_DIR/ghostty"
GHOSTTY_TEMPLATE="$GHOSTTY_CONFIG_DIR/config.template"
GHOSTTY_OUTPUT_CONFIG="$GHOSTTY_CONFIG_DIR/config"

GTK3_DIR="$CONFIG_DIR/gtk-3.0"
GTK3_TEMPLATE="$GTK3_DIR/gtk.css.template"
GTK3_OUTPUT="$GTK3_DIR/gtk.css"

GTK4_DIR="$CONFIG_DIR/gtk-4.0"
GTK4_TEMPLATE="$GTK4_DIR/gtk.css.template"
GTK4_OUTPUT="$GTK4_DIR/gtk.css"

ZED_THEME_WAL_DIR="$CONFIG_DIR/zed-theme-wal"
ZED_GENERATE_THEME_SCRIPT="$ZED_THEME_WAL_DIR/generate_theme"

EWW_CONFIG_DIR="$CONFIG_DIR/eww"
EWW_TEMPLATE="$EWW_CONFIG_DIR/eww.scss.template"
EWW_OUTPUT_CSS="$EWW_CONFIG_DIR/eww.scss"

# --- Load Pywal colors ---
if [ -f "$COLORS_SH" ]; then
    echo "Sourcing Pywal colors from $COLORS_SH..."
    source "$COLORS_SH"
else
    echo "colors.sh not found, attempting JSON fallback at $COLORS_JSON..." >&2
    if [ -f "$COLORS_JSON" ]; then
        # Export colors from JSON using python (jq-free fallback)
        eval "$(COLORS_JSON_PATH=\"$COLORS_JSON\" /usr/bin/env python3 - <<'PY'
import json, os, sys
p = os.environ.get('COLORS_JSON_PATH')
try:
    with open(p, 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"echo 'Error reading {p}: {e}' >&2")
    sys.exit(1)
colors = data.get('colors', {})
wp = data.get('wallpaper', '')
for i in range(16):
    k = f'color{i}'
    v = colors.get(k)
    if v is not None:
        # Quote the hex so shell doesn't treat # as comment
        print(f"export {k}='{v}'")
if wp:
    # Quote wallpaper path safely
    print(f"export wallpaper='{wp}'")
PY
)"
        echo "Loaded colors from JSON fallback"
    else
        echo "Error: Neither $COLORS_SH nor $COLORS_JSON found. Aborting." >&2
        exit 1
    fi
fi

# If wal didn't rewrite colors.sh (cache hit), ensure wallpaper path is fresh
if [ -f "$CACHE_DIR/wallpaper" ]; then
    CURRENT_WALLPAPER_FILE=$(cat "$CACHE_DIR/wallpaper" 2>/dev/null || true)
    if [ -n "$CURRENT_WALLPAPER_FILE" ]; then
        wallpaper="$CURRENT_WALLPAPER_FILE"
        export wallpaper
        echo "[apply] Using wallpaper from $CACHE_DIR/wallpaper: $wallpaper"
    fi
fi


# --- Verify Sourced Colors ---
echo "Verifying sourced colors..."
if [ -z "$color0" ] || [ -z "$color7" ] || [ -z "$color8" ] || [ -z "$wallpaper" ]; then
    echo "Error: Required Pywal colors (e.g., color0..8) or wallpaper path not found or empty in $COLORS_SH." >&2
    echo "Please ensure Pywal ran successfully and generated $COLORS_SH." >&2
    exit 1
fi
echo "Color verification successful (color0..8 and wallpaper)"

# --- Export Core Colors for envsubst ---
# Exporting ensures envsubst definitely sees them
export color0 color1 color2 color3 color4 color5 color6 color7 color8 wallpaper

# --- Helper Function ---
# Converts hex color (e.g., #aabbcc) to R,G,B format (e.g., 170,187,204)
hex_to_rgb() {
    local hex=${1#"#"} # Remove leading # if present
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "$r,$g,$b"
}

# --- Keyboard brightness helpers ---
KBD_BRIGHTNESS_PATH="/sys/class/leds/asus::kbd_backlight/brightness"

get_kbd_brightness() {
    if [ -r "$KBD_BRIGHTNESS_PATH" ]; then
        cat "$KBD_BRIGHTNESS_PATH" 2>/dev/null || true
    fi
}

set_kbd_brightness() {
    local level="$1"
    # Map numeric to asusctl modes; fallback to writing sysfs directly
    local mode=""
    case "$level" in
        0) mode="off" ;;
        1) mode="low" ;;
        2) mode="med" ;;
        3) mode="high" ;;
    esac

    if [ -n "$mode" ] && command -v asusctl >/dev/null 2>&1; then
        asusctl --kbd-bright "$mode" >/dev/null 2>&1 && return 0
    fi

    if [ -n "$level" ] && [ -w "$KBD_BRIGHTNESS_PATH" ]; then
        echo "$level" > "$KBD_BRIGHTNESS_PATH" 2>/dev/null && return 0
    fi

    return 1
}

# --- Calculate RGB Colors ---
# These are needed for rgba() colors in the Waybar template
echo "Calculating RGB colors..."
color0_rgb=$(hex_to_rgb "$color0")
color1_rgb=$(hex_to_rgb "$color1")
color2_rgb=$(hex_to_rgb "$color2")
color3_rgb=$(hex_to_rgb "$color3")
color4_rgb=$(hex_to_rgb "$color4")
color5_rgb=$(hex_to_rgb "$color5")
color6_rgb=$(hex_to_rgb "$color6")
color7_rgb=$(hex_to_rgb "$color7")
color8_rgb=$(hex_to_rgb "$color8")

# --- Process Waybar CSS ---
echo "Processing Waybar template: $WAYBAR_TEMPLATE -> $WAYBAR_OUTPUT_CSS"
__t_waybar=$(now_ms)
WAYBAR_CHANGED=0
if [ ! -f "$WAYBAR_TEMPLATE" ]; then
    echo "Error: Waybar template not found at $WAYBAR_TEMPLATE" >&2
    exit 1
fi

# Export the calculated RGB vars so envsubst can find them
export color0_rgb color1_rgb color2_rgb color3_rgb color4_rgb color5_rgb color6_rgb color7_rgb color8_rgb

# Ensure the variables list for envsubst only contains valid shell variable names ($ or ${})
# The previous list was okay, but this is slightly safer if variable names had dashes etc.
WAYBAR_VARS='${color0}:${color1}:${color2}:${color3}:${color4}:${color5}:${color6}:${color7}:${color8}:${color0_rgb}:${color1_rgb}:${color2_rgb}:${color3_rgb}:${color4_rgb}:${color5_rgb}:${color6_rgb}:${color7_rgb}:${color8_rgb}:$HOME'

PRE_HASH=$(sha256sum "$WAYBAR_OUTPUT_CSS" 2>/dev/null | awk '{print $1}' || echo none)
tmp_waybar=$(mktemp)
envsubst "$WAYBAR_VARS" < "$WAYBAR_TEMPLATE" > "$tmp_waybar"
STATUS=$(write_if_changed "$tmp_waybar" "$WAYBAR_OUTPUT_CSS" || true)
if [ "$STATUS" = "changed" ]; then
    WAYBAR_CHANGED=1
fi
POST_HASH=$(sha256sum "$WAYBAR_OUTPUT_CSS" 2>/dev/null | awk '{print $1}' || echo none)
echo "[waybar-css] pre=$PRE_HASH post=$POST_HASH changed=$WAYBAR_CHANGED"
log_step "waybar-css" "$__t_waybar"

# --- Process Swaync CSS ---
echo "Processing Swaync template: $SWAYNC_TEMPLATE -> $SWAYNC_OUTPUT_CSS"
__t_swaync=$(now_ms)
SWAYNC_CHANGED=0
if [ ! -f "$SWAYNC_TEMPLATE" ]; then
    echo "Error: Swaync template not found at $SWAYNC_TEMPLATE" >&2
    # Don't exit, maybe user doesn't have swaync
else
    # Define vars needed by swaync template
    SWAYNC_VARS='${color0_rgb}:${color2_rgb}:${color7_rgb}:${color8_rgb}'
    tmp_swaync=$(mktemp)
    envsubst "$SWAYNC_VARS" < "$SWAYNC_TEMPLATE" > "$tmp_swaync"
    SWAYNC_STATUS=$(write_if_changed "$tmp_swaync" "$SWAYNC_OUTPUT_CSS" || true)
    if [ "$SWAYNC_STATUS" = "changed" ]; then
        SWAYNC_CHANGED=1
    fi
    log_step "swaync-css" "$__t_swaync"
fi

# --- Process Wlogout CSS ---
echo "Processing Wlogout template: $WLOGOUT_TEMPLATE -> $WLOGOUT_OUTPUT_CSS"
__t_wlogout_css=$(now_ms)
if [ ! -f "$WLOGOUT_TEMPLATE" ]; then
    echo "Warning: Wlogout template not found at $WLOGOUT_TEMPLATE" >&2
else
    # Define vars needed by wlogout template (includes HOME for icon path)
    WLOGOUT_VARS='${color0_rgb}:${color2_rgb}:${color7_rgb}:$HOME'
    tmp_wlogout=$(mktemp)
    envsubst "$WLOGOUT_VARS" < "$WLOGOUT_TEMPLATE" > "$tmp_wlogout"
    write_if_changed "$tmp_wlogout" "$WLOGOUT_OUTPUT_CSS" >/dev/null || true
    log_step "wlogout-css" "$__t_wlogout_css"
fi

# --- Generate Wlogout Icons ---
echo "Generating Wlogout icons in $WLOGOUT_ICONS_DIR"
__t_wlogout_icns=$(now_ms)
mkdir -p "$WLOGOUT_ICONS_DIR"
wlogout_icons="lock logout suspend hibernate shutdown reboot"
for icon in $wlogout_icons; do
    src_icon="$WLOGOUT_ASSETS_DIR/${icon}.svg"
    dest_icon="$WLOGOUT_ICONS_DIR/${icon}.svg"
    if [ -f "$src_icon" ]; then
        echo "  Generating ${icon}.svg..."
        # Replace black/grayscale with color2, preserve others
        sed -e "s/\#000000/${color2}/g" \
            -e "s/\#000/${color2}/g" \
            -e "s/black/${color2}/g" \
            -e "s/\#808080/${color8}/g" \
            -e "s/grey/${color8}/g" \
            -e "s/gray/${color8}/g" \
            "$src_icon" > "$dest_icon"
    else
        echo "  Warning: Source icon not found: $src_icon" >&2
    fi
done
log_step "wlogout-icons" "$__t_wlogout_icns"

# --- Process Swaylock Config ---
echo "Processing Swaylock template: $SWAYLOCK_TEMPLATE -> $SWAYLOCK_OUTPUT_CONFIG"
__t_swaylock=$(now_ms)
if [ ! -f "$SWAYLOCK_TEMPLATE" ]; then
    echo "Warning: Swaylock template not found at $SWAYLOCK_TEMPLATE" >&2
else
    # Define vars needed by swaylock template
    SWAYLOCK_VARS='${wallpaper}:${color0_rgb}:${color1_rgb}:${color2_rgb}:${color3_rgb}:${color4_rgb}:${color5_rgb}:${color6_rgb}:${color7_rgb}:${color8_rgb}'
    tmp_swaylock=$(mktemp)
    envsubst "$SWAYLOCK_VARS" < "$SWAYLOCK_TEMPLATE" > "$tmp_swaylock"
    write_if_changed "$tmp_swaylock" "$SWAYLOCK_OUTPUT_CONFIG" >/dev/null || true
    log_step "swaylock-config" "$__t_swaylock"
fi

# --- Generate Rofi Files ---

# 1. Generate colors.rasi (for config.rasi)
echo "Generating Rofi colors file: $ROFI_COLORS_RASI"
__t_rofi_colors=$(now_ms)
mkdir -p "$ROFI_CONFIG_DIR"
cat > "$ROFI_COLORS_RASI" << EOF
/* Generated by apply_wal_outputs.sh */
* {
    background:     rgba(${color0_rgb}, 0.90);
    background-alt: rgba(${color1_rgb}, 0.90);
    foreground:     $color7;
    selected:       $color4; /* Standard Rofi selected often maps to Accent */
    active:         $color5; /* Standard Rofi active */
    urgent:         $color3; /* Standard Rofi urgent */
}
EOF
log_step "rofi-colors" "$__t_rofi_colors"

# 2. Generate wallpaper.rasi (from template)
echo "Processing Rofi wallpaper theme: $ROFI_WALLPAPER_TEMPLATE -> $ROFI_WALLPAPER_OUTPUT"
__t_rofi_wall=$(now_ms)
if [ ! -f "$ROFI_WALLPAPER_TEMPLATE" ]; then
    echo "Error: Rofi wallpaper template not found at $ROFI_WALLPAPER_TEMPLATE" >&2
    # Don't exit, maybe user doesn't use this Rofi theme
else
    # Define vars needed by rofi wallpaper template
    ROFI_WALLPAPER_VARS='${color0_rgb}:${color1_rgb}:${color4}:${color7}'
    tmp_rofi_wall=$(mktemp)
    envsubst "$ROFI_WALLPAPER_VARS" < "$ROFI_WALLPAPER_TEMPLATE" > "$tmp_rofi_wall"
    write_if_changed "$tmp_rofi_wall" "$ROFI_WALLPAPER_OUTPUT" >/dev/null || true
    log_step "rofi-wallpaper" "$__t_rofi_wall"
fi

# --- Process Ghostty Config ---
echo "Processing Ghostty template: $GHOSTTY_TEMPLATE -> $GHOSTTY_OUTPUT_CONFIG"
__t_ghostty=$(now_ms)
if [ ! -f "$GHOSTTY_TEMPLATE" ]; then
    echo "Warning: Ghostty template not found at $GHOSTTY_TEMPLATE" >&2
else
    # Define vars needed by ghostty template
    GHOSTTY_VARS='${color0}:${color1}:${color2}:${color3}:${color4}:${color5}:${color6}:${color7}:${color8}'
    tmp_ghostty=$(mktemp)
    envsubst "$GHOSTTY_VARS" < "$GHOSTTY_TEMPLATE" > "$tmp_ghostty"
    write_if_changed "$tmp_ghostty" "$GHOSTTY_OUTPUT_CONFIG" >/dev/null || true
    log_step "ghostty-config" "$__t_ghostty"
fi

# --- Process GTK-3.0 CSS ---
echo "Processing GTK-3.0 template: $GTK3_TEMPLATE -> $GTK3_OUTPUT"
__t_gtk3=$(now_ms)
if [ -f "$GTK3_TEMPLATE" ]; then
    # Define vars needed by GTK-3.0 template
    GTK3_VARS='${color0_rgb}:${color1_rgb}:${color2_rgb}:${color3_rgb}:${color4_rgb}:${color5_rgb}:${color6_rgb}:${color7_rgb}:${color8_rgb}'
    tmp_gtk3=$(mktemp)
    envsubst "$GTK3_VARS" < "$GTK3_TEMPLATE" > "$tmp_gtk3"
    write_if_changed "$tmp_gtk3" "$GTK3_OUTPUT" >/dev/null || true
    log_step "gtk3-css" "$__t_gtk3"
else
    echo "Warning: GTK-3.0 template not found at $GTK3_TEMPLATE" >&2
fi

# --- Process GTK-4.0 CSS ---
echo "Processing GTK-4.0 template: $GTK4_TEMPLATE -> $GTK4_OUTPUT"
__t_gtk4=$(now_ms)
if [ -f "$GTK4_TEMPLATE" ]; then
    # Define vars needed by GTK-4.0 template
    GTK4_VARS='${color0_rgb}:${color1_rgb}:${color2_rgb}:${color3_rgb}:${color4_rgb}:${color5_rgb}:${color6_rgb}:${color7_rgb}:${color8_rgb}'
    tmp_gtk4=$(mktemp)
    envsubst "$GTK4_VARS" < "$GTK4_TEMPLATE" > "$tmp_gtk4"
    write_if_changed "$tmp_gtk4" "$GTK4_OUTPUT" >/dev/null || true
    log_step "gtk4-css" "$__t_gtk4"
else
    echo "Warning: GTK-4.0 template not found at $GTK4_TEMPLATE" >&2
fi

# --- Process eww CSS ---
echo "Processing eww template: $EWW_TEMPLATE -> $EWW_OUTPUT_CSS"
__t_eww=$(now_ms)
EWW_CHANGED=0
if [ -f "$EWW_TEMPLATE" ]; then
    # We need to export all color variables including extended colors for eww
    # eww template uses color9-color15 for hover states
    export color9 color10 color11 color12 color13 color14 color15

    # Calculate RGB for extended colors if they exist
    if [ -n "$color9" ]; then
        color9_rgb=$(hex_to_rgb "$color9")
        export color9_rgb
    fi
    if [ -n "$color10" ]; then
        color10_rgb=$(hex_to_rgb "$color10")
        export color10_rgb
    fi
    if [ -n "$color11" ]; then
        color11_rgb=$(hex_to_rgb "$color11")
        export color11_rgb
    fi
    if [ -n "$color12" ]; then
        color12_rgb=$(hex_to_rgb "$color12")
        export color12_rgb
    fi
    if [ -n "$color13" ]; then
        color13_rgb=$(hex_to_rgb "$color13")
        export color13_rgb
    fi
    if [ -n "$color14" ]; then
        color14_rgb=$(hex_to_rgb "$color14")
        export color14_rgb
    fi
    if [ -n "$color15" ]; then
        color15_rgb=$(hex_to_rgb "$color15")
        export color15_rgb
    fi

    # Define vars needed by eww template
    EWW_VARS='${color0}:${color1}:${color2}:${color3}:${color4}:${color5}:${color6}:${color7}:${color8}:${color9}:${color10}:${color11}:${color12}:${color13}:${color14}:${color15}:${color0_rgb}:${color1_rgb}:${color2_rgb}:${color3_rgb}:${color4_rgb}:${color5_rgb}:${color6_rgb}:${color7_rgb}:${color8_rgb}:${color9_rgb}:${color10_rgb}:${color11_rgb}:${color12_rgb}:${color13_rgb}:${color14_rgb}:${color15_rgb}'
    tmp_eww=$(mktemp)
    envsubst "$EWW_VARS" < "$EWW_TEMPLATE" > "$tmp_eww"
    EWW_STATUS=$(write_if_changed "$tmp_eww" "$EWW_OUTPUT_CSS" || true)
    if [ "$EWW_STATUS" = "changed" ]; then
        EWW_CHANGED=1
    fi
    log_step "eww-css" "$__t_eww"
else
    echo "Warning: eww template not found at $EWW_TEMPLATE" >&2
fi

# Zed theme generation removed by user request

# Waybar Perplexity SVG generation removed by user request

# Waybar icon theming removed by user request

echo "Applying changes that require service restarts..."
__t_restart=$(now_ms)

# Restart eww if the template was processed
if [ "$EWW_CHANGED" = 1 ] && command -v eww &> /dev/null; then
    echo "Restarting eww (async)..."
    ( eww reload || echo "Warning: eww reload failed." ) &
fi

# Restart swaync if the template was processed
if [ "$SWAYNC_CHANGED" = 1 ] && command -v swaync-client &> /dev/null; then
    echo "Restarting swaync (async)..."
    ( swaync-client -rs || echo "Warning: swaync-client -rs failed." ) &
fi

# Reload waybar if its CSS changed (synchronous to guarantee pickup)
if [ "$WAYBAR_CHANGED" = 1 ] && pgrep waybar >/dev/null; then
    echo "Reloading Waybar due to CSS change..."
    killall -SIGUSR2 waybar || true
fi

log_step "service-restarts" "$__t_restart"

# Removed pywalfox update step

# Set keyboard color (prefer asusctl, fallback to rogauracore)
KB_COLOR="${color4#\#}"
ORIG_KBD_BRIGHT=$(get_kbd_brightness)
if command -v asusctl &> /dev/null; then
    __t_asusctl=$(now_ms)
    echo "Setting keyboard color using asusctl (async)..."
    (
        asusctl aura static -c "$KB_COLOR" >/dev/null 2>&1 && echo "Successfully set keyboard color to ${color4} via asusctl" || echo "Warning: Failed to set keyboard color via asusctl."
        if [ -n "$ORIG_KBD_BRIGHT" ]; then
            set_kbd_brightness "$ORIG_KBD_BRIGHT" || true
        fi
    ) &
    log_step "asusctl" "$__t_asusctl"
elif command -v rogauracore &> /dev/null; then
    __t_roga=$(now_ms)
    echo "Setting keyboard color using rogauracore (async)..."
    (
        rogauracore single_static "$KB_COLOR" >/dev/null 2>&1 && echo "Successfully set keyboard color to ${color4}" || echo "Warning: Failed to set keyboard color."
        if [ -n "$ORIG_KBD_BRIGHT" ]; then
            set_kbd_brightness "$ORIG_KBD_BRIGHT" || true
        fi
    ) &
    log_step "rogauracore" "$__t_roga"
else
    echo "Warning: asusctl or rogauracore not found, skipping keyboard color update"
fi

echo "apply_wal_outputs.sh finished successfully."

# --- Update Hyprland border colors dynamically ---
__t_hyprctl=$(now_ms)
if command -v hyprctl &> /dev/null; then
    # Use active accent as a gradient and softened inactive border
    # Convert hex like #aabbcc to 0xffaabbcc
    to_rgba_ff() {
        local hex=${1#"#"}
        echo "0xff${hex}"
    }
    ACTIVE_A=$(to_rgba_ff "$color4")
    ACTIVE_B=$(to_rgba_ff "$color1")
    INACTIVE=$(to_rgba_ff "${color7#\#}")

    # Apply unified solid color border
    hyprctl keyword general:col.active_border "$ACTIVE_A" >/dev/null 2>&1 || true
    hyprctl keyword general:col.inactive_border "$INACTIVE" >/dev/null 2>&1 || true
fi
log_step "hyprctl-borders" "$__t_hyprctl"

# Total
log_step "TOTAL apply_wal_outputs.sh" "$__t_total"
