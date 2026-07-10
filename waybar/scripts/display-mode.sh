#!/bin/bash
# Report the active display mode for Waybar.
"$HOME/.config/hypr/scripts/display-manager.sh" status-json | awk '/^[[:space:]]*\{/ { print; exit }'
