#!/usr/bin/env sh

# Terminate already running bar instances
killall -q waybar

# Wait until the processes have been shut down
while pgrep -x waybar >/dev/null; do sleep 1; done

# Launch main
waybar &
WAYBAR_PID=$!

# Wait for waybar to be ready, then signal the screen recording indicator
# so it immediately reflects any active recording that survived the restart
(
    sleep 2
    pkill -RTMIN+8 waybar
) &

wait $WAYBAR_PID
