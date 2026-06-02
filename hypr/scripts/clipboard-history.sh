#!/usr/bin/env bash
set -euo pipefail

selection=$(cliphist list | rofi -dmenu -i -theme "$HOME/.config/rofi/config.rasi" -p "")
[ -n "$selection" ] || exit 0

printf '%s' "$selection" | cliphist decode | wl-copy
