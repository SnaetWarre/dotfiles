#!/bin/bash

# Toggle screen recording with wl-screenrec
if pgrep -x wl-screenrec >/dev/null; then
    # Stop recording
    pkill -SIGINT wl-screenrec
    notify-send "Screen Recording" "Recording stopped" -i video-x-generic
else
    # Start recording
    # Create videos directory if it doesn't exist
    mkdir -p ~/Videos
    
    # Generate filename with timestamp
    FILENAME=~/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4
    
    # Get the default audio sink monitor (desktop audio output)
    # This captures what's playing on your desktop, not microphone input
    DEFAULT_SINK=$(pactl get-default-sink)
    AUDIO_SOURCE="${DEFAULT_SINK}.monitor"
    
    # Start recording with desktop audio
    wl-screenrec --audio --audio-device "$AUDIO_SOURCE" -f "$FILENAME" &
    notify-send "Screen Recording" "Recording started with audio" -i video-x-generic
fi

# Signal waybar to update
pkill -RTMIN+8 waybar
