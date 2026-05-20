#!/bin/bash

SESSION_FILE="/tmp/screenrec-session"

session_pid() {
    [ -f "$SESSION_FILE" ] || return 1
    PID=$(cut -d: -f1 "$SESSION_FILE")
    case "$PID" in
        ''|*[!0-9]*|0) return 1 ;;
    esac
    printf '%s\n' "$PID"
}

is_recording() {
    PID=$(session_pid) && kill -0 "$PID" 2>/dev/null
}

if is_recording; then
    PID=$(session_pid)
    kill -SIGINT "$PID"
    systemctl --user stop screenrec-session.service >/dev/null 2>&1 || true
    notify-send "Screen Recording" "Recording stopped" -i video-x-generic
    rm -f "$SESSION_FILE"
else
    rm -f "$SESSION_FILE"
    mkdir -p ~/Videos
    FILENAME=~/Videos/screenrecord-$(date +%Y%m%d-%H%M%S).mp4

    if ! command -v wf-recorder >/dev/null 2>&1; then
        notify-send "Screen Recording" "wf-recorder is not installed" -i dialog-error
        pkill -RTMIN+8 waybar
        exit 1
    fi

    # Launch fully detached from waybar's process group via a transient systemd
    # user service — survives waybar being killed/restarted (e.g. theme changes)
    systemd-run --user --unit=screenrec-session \
        wf-recorder --framerate 45 -f "$FILENAME"

    # Give systemd a moment to actually start the process
    sleep 0.5

    PID=$(systemctl --user show -p MainPID --value screenrec-session.service)
    case "$PID" in
        ''|*[!0-9]*|0)
            notify-send "Screen Recording" "Failed to start recording" -i dialog-error
            rm -f "$SESSION_FILE"
            pkill -RTMIN+8 waybar
            exit 1
            ;;
    esac
    echo "${PID}:${FILENAME}" > "$SESSION_FILE"
fi

pkill -RTMIN+8 waybar
