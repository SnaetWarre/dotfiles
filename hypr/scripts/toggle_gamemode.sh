#!/bin/bash

GAMEMODE_LOCK_FILE="/tmp/gamemode.lock"
ROFI_KEYS="CTRL, SPACE"
ROFI_COMMAND="exec, rofi -show combi -modi drun,run,combi -combi-modi drun,run -theme ~/.config/rofi/config.rasi"

if [ -f "$GAMEMODE_LOCK_FILE" ]; then
    hyprctl keyword bind "$ROFI_KEYS, $ROFI_COMMAND"
    rm "$GAMEMODE_LOCK_FILE"
    notify-send "Gamemode" "Disabled" -i input-gaming
else
    hyprctl keyword unbind "$ROFI_KEYS"
    touch "$GAMEMODE_LOCK_FILE"
    notify-send "Gamemode" "Enabled" -i input-gaming
fi 