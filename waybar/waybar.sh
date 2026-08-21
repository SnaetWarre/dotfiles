#!/usr/bin/env sh

# Let the packaged user service restart Waybar and its custom monitor processes
# as one cgroup. systemd waits for the old processes to exit without polling.
systemctl --user restart waybar.service

# Wait for waybar to be ready, then signal the screen recording indicator
# so it immediately reflects any active recording that survived the restart
(
    sleep 0.2
    pkill -RTMIN+8 waybar
) &
