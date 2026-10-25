#!/bin/bash
# Toggle all keyboards between the configured layouts (Hyprland or mango).

if pgrep -u "$(id -u)" -x mango >/dev/null; then
  mmsg dispatch switch_keyboard_layout >/dev/null 2>&1
else
  hyprctl switchxkblayout all next >/dev/null 2>&1
fi
pkill -RTMIN+13 waybar 2>/dev/null || true
