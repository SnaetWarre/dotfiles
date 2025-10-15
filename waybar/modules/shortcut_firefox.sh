#!/bin/sh
# Outputs JSON for Waybar custom module with inline img tag for firefox
ICON="$HOME/.config/waybar/icons/firefox.svg"
printf '%s\n' "{\"text\": \"<img src=\\\"$ICON\\\" height=\\\"18\\\"/>\" }"
