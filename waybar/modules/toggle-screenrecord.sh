#!/bin/bash

SESSION_FILE="/tmp/screenrec-session"

is_recording() {
    [ -f "$SESSION_FILE" ] && kill -0 "$(cut -d: -f1 "$SESSION_FILE")" 2>/dev/null
}

if is_recording; then
    PID=$(cut -d: -f1 "$SESSION_FILE")
    kill -SIGINT "$PID"
    notify-send "Screen Recording" "Recording stopped" -i video-x-generic
    rm -f "$SESSION_FILE"
else
    mkdir -p ~/Videos
    FILENAME=~/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4

    # Launch fully detached from waybar's process group via a transient systemd
    # user service — survives waybar being killed/restarted (e.g. theme changes)
    systemd-run --user --unit=screenrec-session \
        wl-screenrec --max-fps 45 -f "$FILENAME" --audio

    # Give systemd a moment to actually start the process
    sleep 0.5

    PID=$(systemctl --user show -p MainPID --value screenrec-session.service)
    echo "${PID}:${FILENAME}" > "$SESSION_FILE"
fi

pkill -RTMIN+8 waybar
