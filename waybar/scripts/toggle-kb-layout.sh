#!/bin/bash
# Toggle all Hyprland keyboards between the configured layouts.

hyprctl switchxkblayout all next >/dev/null 2>&1
pkill -RTMIN+13 waybar 2>/dev/null || true
