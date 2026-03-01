#!/bin/bash

SESSION_FILE="/tmp/screenrec-session"

if [ -f "$SESSION_FILE" ] && kill -0 "$(cut -d: -f1 "$SESSION_FILE")" 2>/dev/null; then
    echo '{"text": "󰑊", "tooltip": "Stop recording", "class": "recording"}'
else
    # Clean up stale session file if the process is gone
    rm -f "$SESSION_FILE"
    echo '{"text": "󰑊", "tooltip": "Start recording", "class": "idle"}'
fi
