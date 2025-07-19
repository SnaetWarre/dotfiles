#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wal"
COLORS_SH="$CACHE_DIR/colors.sh"
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

# --- Check for Pywal colors ---
if [ ! -f "$COLORS_SH" ]; then
    echo "Error: Pywal color file not found at $COLORS_SH" >&2
    exit 1
fi

echo "Sourcing Pywal colors from $COLORS_SH..."
source "$COLORS_SH"


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
if [ ! -f "$WAYBAR_TEMPLATE" ]; then
    echo "Error: Waybar template not found at $WAYBAR_TEMPLATE" >&2
    exit 1
fi

# Export the calculated RGB vars so envsubst can find them
export color0_rgb color1_rgb color2_rgb color3_rgb color4_rgb color5_rgb color6_rgb color7_rgb color8_rgb

# Ensure the variables list for envsubst only contains valid shell variable names ($ or ${})
# The previous list was okay, but this is slightly safer if variable names had dashes etc.
WAYBAR_VARS='${color0}:${color1}:${color2}:${color3}:${color4}:${color5}:${color6}:${color7}:${color8}:${color0_rgb}:${color1_rgb}:${color2_rgb}:${color3_rgb}:${color4_rgb}:${color5_rgb}:${color6_rgb}:${color7_rgb}:${color8_rgb}'

envsubst "$WAYBAR_VARS" < "$WAYBAR_TEMPLATE" > "$WAYBAR_OUTPUT_CSS"

# --- Process Swaync CSS ---
echo "Processing Swaync template: $SWAYNC_TEMPLATE -> $SWAYNC_OUTPUT_CSS"
if [ ! -f "$SWAYNC_TEMPLATE" ]; then
    echo "Error: Swaync template not found at $SWAYNC_TEMPLATE" >&2
    # Don't exit, maybe user doesn't have swaync
else
    # Define vars needed by swaync template
    SWAYNC_VARS='${color0_rgb}:${color2_rgb}:${color7_rgb}:${color8_rgb}'
    envsubst "$SWAYNC_VARS" < "$SWAYNC_TEMPLATE" > "$SWAYNC_OUTPUT_CSS"
fi

# --- Process Wlogout CSS ---
echo "Processing Wlogout template: $WLOGOUT_TEMPLATE -> $WLOGOUT_OUTPUT_CSS"
if [ ! -f "$WLOGOUT_TEMPLATE" ]; then
    echo "Warning: Wlogout template not found at $WLOGOUT_TEMPLATE" >&2
else
    # Define vars needed by wlogout template (includes HOME for icon path)
    WLOGOUT_VARS='${color0_rgb}:${color2_rgb}:${color7_rgb}:$HOME'
    envsubst "$WLOGOUT_VARS" < "$WLOGOUT_TEMPLATE" > "$WLOGOUT_OUTPUT_CSS"
fi

# --- Generate Wlogout Icons ---
echo "Generating Wlogout icons in $WLOGOUT_ICONS_DIR"
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

# --- Process Swaylock Config ---
echo "Processing Swaylock template: $SWAYLOCK_TEMPLATE -> $SWAYLOCK_OUTPUT_CONFIG"
if [ ! -f "$SWAYLOCK_TEMPLATE" ]; then
    echo "Warning: Swaylock template not found at $SWAYLOCK_TEMPLATE" >&2
else
    # Define vars needed by swaylock template
    SWAYLOCK_VARS='${wallpaper}:${color0_rgb}:${color1_rgb}:${color2_rgb}:${color3_rgb}:${color4_rgb}:${color5_rgb}:${color6_rgb}:${color7_rgb}:${color8_rgb}'
    envsubst "$SWAYLOCK_VARS" < "$SWAYLOCK_TEMPLATE" > "$SWAYLOCK_OUTPUT_CONFIG"
fi

# --- Generate Rofi Files ---

# 1. Generate colors.rasi (for config.rasi)
echo "Generating Rofi colors file: $ROFI_COLORS_RASI"
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

# 2. Generate wallpaper.rasi (from template)
echo "Processing Rofi wallpaper theme: $ROFI_WALLPAPER_TEMPLATE -> $ROFI_WALLPAPER_OUTPUT"
if [ ! -f "$ROFI_WALLPAPER_TEMPLATE" ]; then
    echo "Error: Rofi wallpaper template not found at $ROFI_WALLPAPER_TEMPLATE" >&2
    # Don't exit, maybe user doesn't use this Rofi theme
else
    # Define vars needed by rofi wallpaper template
    ROFI_WALLPAPER_VARS='${color0_rgb}:${color1_rgb}:${color4}:${color7}'
    envsubst "$ROFI_WALLPAPER_VARS" < "$ROFI_WALLPAPER_TEMPLATE" > "$ROFI_WALLPAPER_OUTPUT"
fi

# --- Process Ghostty Config ---
echo "Processing Ghostty template: $GHOSTTY_TEMPLATE -> $GHOSTTY_OUTPUT_CONFIG"
if [ ! -f "$GHOSTTY_TEMPLATE" ]; then
    echo "Warning: Ghostty template not found at $GHOSTTY_TEMPLATE" >&2
else
    # Define vars needed by ghostty template
    GHOSTTY_VARS='${color0}:${color1}:${color2}:${color3}:${color4}:${color5}:${color6}:${color7}:${color8}'
    envsubst "$GHOSTTY_VARS" < "$GHOSTTY_TEMPLATE" > "$GHOSTTY_OUTPUT_CONFIG"
fi

# --- Generate Perplexity SVG ---
echo "Generating Perplexity SVG: $PERPLEXITY_SVG"
mkdir -p "$WAYBAR_ICONS_DIR"
cat > "$PERPLEXITY_SVG" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" image-rendering="optimizeQuality" fill-rule="evenodd" clip-rule="evenodd" viewBox="0 0 512 509.64">
    <path fill="$color6" d="M115.613 0h280.774C459.974 0 512 52.025 512 115.612v278.415c0 63.587-52.026 115.613-115.613 115.613H115.613C52.026 509.64 0 457.614 0 394.027V115.612C0 52.025 52.026 0 115.613 0z"/>
    <path fill="$color0" fill-rule="nonzero" d="M348.851 128.063l-68.946 58.302h68.946v-58.302zm-83.908 48.709l100.931-85.349v94.942h32.244v143.421h-38.731v90.004l-94.442-86.662v83.946h-17.023v-83.906l-96.596 86.246v-89.628h-37.445V186.365h38.732V90.768l95.309 84.958v-83.16h17.023l-.002 84.206zm-29.209 26.616c-34.955.02-69.893 0-104.83 0v109.375h20.415v-27.121l84.415-82.254zm41.445 0l82.208 82.324v27.051h21.708V203.388c-34.617 0-69.274.02-103.916 0zm-42.874-17.023l-64.669-57.646v57.646h64.669zm13.617 124.076v-95.2l-79.573 77.516v88.731l79.573-71.047zm17.252-95.022v94.863l77.19 70.83c0-29.485-.012-58.943-.012-88.425l-77.178-77.268z"/>
</svg>
EOF

echo "Applying changes that require service restarts..."

# Restart swaync if the template was processed
if [ -f "$SWAYNC_OUTPUT_CSS" ] && command -v swaync-client &> /dev/null; then
    echo "Restarting swaync..."
    swaync-client -rs || echo "Warning: swaync-client -rs failed."
fi

# updating firefox with it
pywalfox update

echo "updated firefox colors"

# Set keyboard color using rogauracore
if command -v rogauracore &> /dev/null; then
    echo "Setting keyboard color using rogauracore..."
    # Use color4 (accent color) for the keyboard
    if rogauracore single_static "${color4#\#}"; then
        echo "Successfully set keyboard color to ${color4}"
    else
        echo "Warning: Failed to set keyboard color. Make sure udev rules are properly set up."
    fi
else
    echo "Warning: rogauracore not found, skipping keyboard color update"
fi

echo "apply_wal_outputs.sh finished successfully."
