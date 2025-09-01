#!/bin/bash

# Directory containing themes
THEMES_DIR="$HOME/.config/hypr/themes"

# Get list of available themes
THEMES=$(find "$THEMES_DIR" -maxdepth 1 -type d -name "*" | grep -v "^$THEMES_DIR$" | xargs -I {} basename {})

# Create a temporary file for the theme menu
TEMP_FILE=$(mktemp)

# For each theme, create a menu entry with background preview
while IFS= read -r theme; do
    if [ -f "$THEMES_DIR/$theme/colors.sh" ]; then
        # Find the background image for this theme
        background=""
        if [ -d "$THEMES_DIR/$theme/backgrounds" ]; then
            background=$(find "$THEMES_DIR/$theme/backgrounds" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | head -1)
        fi
        
        # Create menu entry with theme name and background
        if [ -n "$background" ]; then
            echo -e "$theme\0icon\x1f$background" >> "$TEMP_FILE"
        else
            echo -e "$theme" >> "$TEMP_FILE"
        fi
    fi
done <<< "$THEMES"

# Show rofi menu with theme selection
SELECTED=$(cat "$TEMP_FILE" | rofi -dmenu -i -p "Select Theme" -theme ~/.config/rofi/wallpaper.rasi -show-icons -icon-theme "Papirus" -modi "icons" -show icons)

# Clean up temp file
rm "$TEMP_FILE"

# If a theme was selected
if [ -n "$SELECTED" ]; then
    echo "Theme selected: $SELECTED"
    
    if [ -f "$THEMES_DIR/$SELECTED/colors.sh" ]; then
        # If the theme has multiple backgrounds, let the user choose one
        BG_DIR="$THEMES_DIR/$SELECTED/backgrounds"
        if [ -d "$BG_DIR" ]; then
            mapfile -t BG_LIST < <(find "$BG_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \))
        else
            BG_LIST=()
        fi

        if [ ${#BG_LIST[@]} -gt 0 ]; then
            BG_TEMP_FILE=$(mktemp)
            for bg in "${BG_LIST[@]}"; do
                fname=$(basename "$bg")
                echo -e "$fname\0icon\x1f$bg" >> "$BG_TEMP_FILE"
            done

            BG_SELECTED=$(cat "$BG_TEMP_FILE" | rofi -dmenu -i -p "Select Background" -theme ~/.config/rofi/wallpaper.rasi -show-icons -icon-theme "Papirus" -modi "icons" -show icons)
            rm "$BG_TEMP_FILE"

            if [ -n "$BG_SELECTED" ]; then
                # Resolve the full path (handles duplicate names poorly, but ok for typical setups)
                BG_PATH=$(find "$BG_DIR" -type f -name "$BG_SELECTED" | head -n 1)
                if [ -n "$BG_PATH" ] && [ -f "$BG_PATH" ]; then
                    echo "Applying theme: $SELECTED with background: $BG_PATH"
                    wallpaper="$BG_PATH" ~/.config/hypr/scripts/theme-apply.sh "$SELECTED"
                    exit $?
                fi
            fi
        fi

        echo "Applying theme: $SELECTED"
        ~/.config/hypr/scripts/theme-apply.sh "$SELECTED"
    else
        echo "Error: Selected theme not found or invalid!"
        exit 1
    fi
fi
