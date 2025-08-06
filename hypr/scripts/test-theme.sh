#!/bin/bash

# Test Theme System
# Simple script to test the current theme configuration

set -e

THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/current_theme"

echo "=== Theme System Test ==="
echo

# Check if current theme file exists
if [ -f "$CURRENT_THEME_FILE" ]; then
    CURRENT_THEME=$(cat "$CURRENT_THEME_FILE")
    echo "Current theme: $CURRENT_THEME"
else
    echo "No current theme file found"
    CURRENT_THEME=""
fi

echo

# Check theme directory
if [ -n "$CURRENT_THEME" ] && [ -d "$THEMES_DIR/$CURRENT_THEME" ]; then
    echo "Theme directory exists: $THEMES_DIR/$CURRENT_THEME"

    # Check required files
    echo "Files in theme directory:"
    ls -la "$THEMES_DIR/$CURRENT_THEME"

    echo
    echo "Required files check:"

    if [ -f "$THEMES_DIR/$CURRENT_THEME/colors.sh" ]; then
        echo "✓ colors.sh exists"
    else
        echo "✗ colors.sh missing"
    fi

    if [ -f "$THEMES_DIR/$CURRENT_THEME/neovim.lua" ]; then
        echo "✓ neovim.lua exists"
        echo "  Content:"
        cat "$THEMES_DIR/$CURRENT_THEME/neovim.lua" | sed 's/^/    /'
    else
        echo "✗ neovim.lua missing"
    fi

    if [ -f "$THEMES_DIR/$CURRENT_THEME/metadata.json" ]; then
        echo "✓ metadata.json exists"
    else
        echo "✗ metadata.json missing"
    fi

else
    echo "Theme directory not found or no current theme set"
fi

echo
echo "Available themes:"
ls -1 "$THEMES_DIR" 2>/dev/null | grep -v current_theme || echo "No themes found"

echo
echo "Neovim theme loader test:"
if [ -f "$HOME/.config/nvim/lua/theme-loader.lua" ]; then
    echo "✓ theme-loader.lua exists"
else
    echo "✗ theme-loader.lua missing"
fi

if [ -f "$HOME/.config/nvim/lua/plugins/themes.lua" ]; then
    echo "✓ plugins/themes.lua exists"
else
    echo "✗ plugins/themes.lua missing"
fi

echo
echo "Environment variables:"
echo "THEME_NAME: ${THEME_NAME:-"(not set)"}"

echo
echo "=== Test Complete ==="
