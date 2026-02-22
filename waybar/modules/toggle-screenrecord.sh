#!/bin/bash

if pgrep -x wl-screenrec >/dev/null || pgrep -x wf-recorder >/dev/null; then
    pkill -SIGINT wl-screenrec
    notify-send "Screen Recording" "Recording stopped" -i video-x-generic
else
    mkdir -p ~/Videos

    FILENAME=~/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4

    wl-screenrec --max-fps 45 -f "$FILENAME" --audio &
fi

pkill -RTMIN+8 waybar
