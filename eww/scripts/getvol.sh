#!/bin/bash

# Function to get volume display
get_volume() {
    local vol
    vol=$(pamixer --get-volume)
    vol=${vol:-0}
    local mute
    mute=$(pamixer --get-mute)

    local icon
    if [ "$mute" = true ] || [ "$vol" -eq 0 ]; then
        icon="󰖁"  # muted
        vol="0"
    elif [ "$vol" -lt 34 ]; then
        icon="󰕿"  # low
    elif [ "$vol" -lt 67 ]; then
        icon="󰖀"  # medium
    else
        icon="󰕾"  # high
    fi

    echo "{\"icon\": \"$icon\", \"volume\": $vol}"
}

# Initial output
get_volume

# Listen for volume changes
pactl subscribe | stdbuf -oL grep --line-buffered "Event 'change' on sink" | while read -r _; do
    get_volume
done
