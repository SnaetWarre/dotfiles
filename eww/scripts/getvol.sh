#!/bin/bash

# Function to update volume display
update_volume() {
    local vol=$(pamixer --get-volume)
    local mute=$(pamixer --get-mute)
    
    if [ "$mute" = true ]; then
        /usr/bin/eww update volico=""
        vol="0"
    else
        /usr/bin/eww update volico=""
    fi
    /usr/bin/eww update get_vol="$vol"
}

# Initial update
update_volume

# Listen for volume changes
pactl subscribe | stdbuf -oL grep --line-buffered "Event 'change' on sink" | while read -r _; do
    update_volume
done
