#!/bin/bash
# ── auto-monitor-detect.sh ─────────────────────────────────────
# Description: Auto-detect HDMI connection and enable mirroring
# Usage: Run as exec-once in hyprland.conf
# ──────────────────────────────────────────────────────────────

# Function to check if HDMI is connected
is_hdmi_connected() {
    hyprctl monitors -j | grep -q '"name":"HDMI-A-1"'
}

# Function to enable mirroring
enable_mirror() {
    echo "[$(date)] HDMI detected - enabling mirror mode" >> ~/.config/hypr/logs/monitor.log
    hyprctl keyword monitor HDMI-A-1, preferred, 0x0, 1, mirror, eDP-2
    notify-send -u low "External Monitor" "HDMI connected - Mirror mode enabled"
}

# Function to disable HDMI
disable_hdmi() {
    echo "[$(date)] HDMI disconnected - disabling" >> ~/.config/hypr/logs/monitor.log
    hyprctl keyword monitor HDMI-A-1, disable
}

# Initial check
if is_hdmi_connected; then
    enable_mirror
fi

# Monitor for changes using hyprland's socket
socat -U - UNIX-CONNECT:/tmp/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "monitoradded>>HDMI-A-1"; then
        enable_mirror
    elif echo "$line" | grep -q "monitorremoved>>HDMI-A-1"; then
        disable_hdmi
    fi
done
