#!/bin/bash

# Toggle screen recording with wf-recorder at 45 fps
if pgrep -x wf-recorder >/dev/null; then
    # Stop recording
    pkill -SIGINT wf-recorder
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

    # Start recording with desktop audio at 45 fps
    wf-recorder -r 45 -f "$FILENAME" -a"$AUDIO_SOURCE" &
    notify-send "Screen Recording" "Recording started with audio at 45 fps" -i video-x-generic
fi

# Signal waybar to update
pkill -RTMIN+8 waybar
