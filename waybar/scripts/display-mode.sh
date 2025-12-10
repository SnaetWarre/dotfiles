#!/bin/bash
# ── display-mode.sh ─────────────────────────────────────────────
# Description: Shows current display mode (mirror/extend)
# Source of truth: ~/.config/hypr/monitors.conf
# ────────────────────────────────────────────────────────────────

MONITORS_CONF="$HOME/.config/hypr/monitors.conf"

# Check if monitors.conf exists
if [ ! -f "$MONITORS_CONF" ]; then
    echo '{"text":"?","tooltip":"monitors.conf not found","class":"unknown"}'
    exit 0
fi

# Check current mode by looking for "mirror" in the HDMI line
if grep -q "mirror, eDP-2" "$MONITORS_CONF"; then
    echo '{"text":"󰍹","tooltip":"Mirroring - Click to extend","class":"mirror"}'
else
    echo '{"text":"󰍺","tooltip":"Extended - Click to mirror","class":"extend"}'
fi
