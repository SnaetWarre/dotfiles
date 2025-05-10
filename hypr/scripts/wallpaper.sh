#!/bin/bash

# Enable debug output
set -x

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
wal -i "$WALLPAPER" -q
if [ $? -ne 0 ]; then
    echo "Error: wal command failed." >&2
    # Decide if you want to exit or continue with potentially old colors
    # exit 1
fi

# Apply colors using the new master script (handles Waybar, Rofi, etc.)
# This script sources the colors internally, ensuring it gets the latest.
echo "Applying Pywal colors via master script..."
if [ -x "$HOME/.config/hypr/scripts/apply_wal_outputs.sh" ]; then
    "$HOME/.config/hypr/scripts/apply_wal_outputs.sh"
else
    echo "Warning: Master script apply_wal_outputs.sh not found or not executable." >&2
fi

# Update wlogout colors (Still needs separate script for now)
echo "Updating wlogout colors..."
WLOGOUT_SCRIPT="$HOME/.config/wlogout/scripts/update-colors.sh"
if [ -x "$WLOGOUT_SCRIPT" ]; then
    "$WLOGOUT_SCRIPT"
else
    echo "Warning: wlogout update script not found or not executable: $WLOGOUT_SCRIPT" >&2
fi

# Rofi update is now handled by apply_wal_outputs.sh
# Set wallpaper with swww
swww img "$WALLPAPER" --transition-duration 0

# Reload Waybar to apply new colors
killall -SIGUSR2 waybar

# Disable debug output
set +x

echo "Done!" 
