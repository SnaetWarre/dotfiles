#!/bin/bash
# Display the active keyboard layout for Waybar (Hyprland or mango).

if pgrep -u "$(id -u)" -x mango >/dev/null; then
  active_keymap=$(mmsg get keyboardlayout 2>/dev/null | jq -r '.layout // empty')
else
  active_keymap=$(hyprctl devices 2>/dev/null | awk -F': ' '/active keymap/ { print $2; exit }')
fi

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

printf '{"text":"KB %s","tooltip":"%s"}\n' "$label" "$tooltip"
