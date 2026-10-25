#!/bin/bash
# Mango version of hypr/scripts/gamemode.sh: Performance profile and no window
# effects while on; turning it off restores the profile and reloads the config.

STATE_FILE="/tmp/gamemode_state"

notify() {
    notify-send -u normal -t 3000 "Game Mode" "$1"
}

if [ -f "$STATE_FILE" ]; then
    asusctl profile set "$(cat "$STATE_FILE")"
    rm -f "$STATE_FILE"
    mmsg dispatch reload_config
    notify "Game Mode OFF (window effects restored)"
else
    asusctl profile get | awk '/Active profile/ {print $NF}' > "$STATE_FILE"
    asusctl profile set Performance
    mmsg dispatch setoption,blur,0
    mmsg dispatch setoption,shadows,0
    mmsg dispatch setoption,animations,0
    mmsg dispatch setoption,layer_animations,0
    notify "Game Mode ON (window effects disabled)"
fi
