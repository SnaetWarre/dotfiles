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

if PID=$(session_pid) && kill -0 "$PID" 2>/dev/null; then
    echo '{"text": "󰑊", "tooltip": "Stop recording", "class": "recording"}'
else
    # Clean up stale session file if the process is gone
    rm -f "$SESSION_FILE"
    echo '{"text": "󰑊", "tooltip": "Start recording", "class": "idle"}'
fi
