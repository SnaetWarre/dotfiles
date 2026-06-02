#!/usr/bin/env bash

rofi_command=(rofi -dmenu -i -theme "$HOME/.config/rofi/config.rasi" -p PWR)

chosen="$(printf '%s\n' shutdown reboot logout suspend lock | "${rofi_command[@]}")"
case "$chosen" in
    shutdown) systemctl poweroff ;;
    reboot) systemctl reboot ;;
    logout)
        if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null 2>&1; then
            hyprctl dispatch exit
        else
            loginctl terminate-user "$USER"
        fi
        ;;
    suspend) systemctl suspend ;;
    lock) swaylock --config "$HOME/.config/swaylock/config" ;;
esac
