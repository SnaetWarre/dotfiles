#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Get list of wallpapers and create preview entries
WALLPAPERS=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \))

# Create a temporary file for the preview menu
TEMP_FILE=$(mktemp)

# For each wallpaper, create a preview entry
while IFS= read -r wallpaper; do
    # Get the filename without path
    filename=$(basename "$wallpaper")
    # Create a preview entry with the image as icon
    echo -e "$filename\0icon\x1f$wallpaper" >> "$TEMP_FILE"
done <<< "$WALLPAPERS"

# Show rofi menu with image previews
SELECTED=$(cat "$TEMP_FILE" | rofi -dmenu -i -p "Select Wallpaper" -theme ~/.config/rofi/wallpaper.rasi -show-icons -icon-theme "Papirus" -columns 3 -modi "run,drun,icons" -show icons)

# Clean up temp file
rm "$TEMP_FILE"

# If a wallpaper was selected
if [ -n "$SELECTED" ]; then
    echo "Wallpaper selected: $SELECTED"
    # Get the full path of the selected wallpaper
    SELECTED_PATH=$(find "$WALLPAPER_DIR" -name "$SELECTED")
    echo "Full path: $SELECTED_PATH"
    
    if [ -f "$SELECTED_PATH" ]; then
        echo "Running wallpaper script..."
        # Run the wallpaper script with the selected wallpaper
        bash -c "source ~/anaconda3/etc/profile.d/conda.sh && conda activate base && ~/.config/hypr/scripts/wallpaper.sh \"$SELECTED_PATH\""
    else
        echo "Error: Selected wallpaper file not found!"
        exit 1
    fi
fi 