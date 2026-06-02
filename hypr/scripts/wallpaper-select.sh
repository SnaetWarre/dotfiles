#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Create a temporary file for the preview menu
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# For each wallpaper, create a preview entry
find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) | sort | while IFS= read -r wallpaper; do
    # Get the filename without path
    filename=$(basename "$wallpaper")
    # Keep the selected value as the full path, but show the basename.
    printf '%s\0icon\x1f%s\0display\x1f%s\n' "$wallpaper" "$wallpaper" "$filename" >> "$TEMP_FILE"
done

# Show rofi menu with image previews
SELECTED=$(cat "$TEMP_FILE" | rofi -dmenu -i -p "Select Wallpaper" -theme ~/.config/rofi/wallpaper.rasi -show-icons -icon-theme "Papirus")

# If a wallpaper was selected
if [ -n "$SELECTED" ]; then
    echo "Wallpaper selected: $SELECTED"
    if [ -f "$SELECTED" ]; then
        echo "Running wallpaper script..."
        # Run the wallpaper script with the selected wallpaper
        ~/.config/hypr/scripts/wallpaper.sh "$SELECTED"
    else
        echo "Error: Selected wallpaper file not found!"
        exit 1
    fi
fi 
