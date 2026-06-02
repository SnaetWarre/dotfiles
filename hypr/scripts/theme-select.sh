#!/bin/bash

# Directory containing themes
THEMES_DIR="$HOME/.config/hypr/themes"

# Get list of available themes
THEMES=$(find "$THEMES_DIR" -maxdepth 1 -type d -name "*" | grep -v "^$THEMES_DIR$" | xargs -I {} basename {})

# Create a temporary file for the theme menu
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE" "${BG_TEMP_FILE:-}"' EXIT

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
            printf '%s\0icon\x1f%s\0display\x1f%s\n' "$theme" "$background" "$theme" >> "$TEMP_FILE"
        else
            printf '%s\n' "$theme" >> "$TEMP_FILE"
        fi
    fi
done <<< "$THEMES"

# Show rofi menu with theme selection
SELECTED=$(cat "$TEMP_FILE" | rofi -dmenu -i -p "Select Theme" -theme ~/.config/rofi/wallpaper.rasi -show-icons -icon-theme "Papirus" -modi "icons" -show icons)

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
                printf '%s\0icon\x1f%s\0display\x1f%s\n' "$bg" "$bg" "$fname" >> "$BG_TEMP_FILE"
            done

            BG_SELECTED=$(cat "$BG_TEMP_FILE" | rofi -dmenu -i -p "Select Background" -theme ~/.config/rofi/wallpaper.rasi -show-icons -icon-theme "Papirus" -modi "icons" -show icons)

            if [ -n "$BG_SELECTED" ]; then
                if [ -f "$BG_SELECTED" ]; then
                    echo "Applying theme: $SELECTED with background: $BG_SELECTED"
                    wallpaper="$BG_SELECTED" ~/.config/hypr/scripts/theme-apply.sh "$SELECTED"
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
