#!/bin/bash
# MangoWC workspace back-and-forth toggle script
# Switches to the target workspace, or if already on it, switches back to the previous one.

TARGET=$1
STATE_FILE="/tmp/mangowc_prev_workspace"

# Get current tag from mmsg (finds the first selected tag)
CURRENT=$(mmsg -g -t | awk '$2=="tag" && $4=="1" {print $3}' | head -n 1)

if [ "$CURRENT" = "$TARGET" ]; then
    if [ -f "$STATE_FILE" ]; then
        PREV=$(cat "$STATE_FILE")
        if [ -n "$PREV" ] && [ "$PREV" != "$CURRENT" ]; then
            # We are going back. Save CURRENT as the new previous so we can toggle back again.
            echo "$CURRENT" > "$STATE_FILE"
            mmsg -s -d view,$PREV,0
        fi
    fi
else
    # We are switching to a new workspace.
    echo "$CURRENT" > "$STATE_FILE"
    mmsg -s -d view,$TARGET,0
fi
