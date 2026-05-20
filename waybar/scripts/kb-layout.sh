#!/bin/bash
# Display the active Hyprland keyboard layout for Waybar.

active_keymap=$(hyprctl devices 2>/dev/null | awk -F': ' '/active keymap/ { print $2; exit }')

case "$active_keymap" in
  *Belgian*|*Belgium*|be)
    label="BE"
    tooltip="Belgian keyboard layout"
    ;;
  *English*|*US*|*American*|us)
    label="US"
    tooltip="US keyboard layout"
    ;;
  "")
    label="??"
    tooltip="Keyboard layout unavailable"
    ;;
  *)
    label="$active_keymap"
    tooltip="$active_keymap"
    ;;
esac

printf '{"text":"󰌌 %s","tooltip":"%s"}\n' "$label" "$tooltip"
