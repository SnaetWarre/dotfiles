#!/bin/bash
# ── display-toggle.sh ─────────────────────────────────────────────
# Description: Toggle between mirroring and extending displays
# Source of truth: ~/.config/hypr/monitors.conf
# ────────────────────────────────────────────────────────────────

MONITORS_CONF="$HOME/.config/hypr/monitors.conf"

# Check if monitors.conf exists
if [ ! -f "$MONITORS_CONF" ]; then
    notify-send "Display Toggle" "monitors.conf not found" -t 2000
    exit 1
fi

# Check current mode by looking for "mirror" in the HDMI line
if grep -q "mirror, eDP-2" "$MONITORS_CONF"; then
    # Currently mirroring, switch to extended
    cat > "$MONITORS_CONF" << 'EOF'
# Monitor Configuration

# Laptop display - 2K@165Hz
monitor = eDP-2, 2560x1440@165, 0x0, 1.0

# External monitor - Extended mode (to the right of laptop)
monitor = HDMI-A-1, preferred, 2560x0, 1

# Fallback for any other monitors
monitor = , preferred, auto, 1
EOF
    hyprctl reload
    notify-send "Display Mode" "Extended" -t 2000
else
    # Currently extended, switch to mirroring
    cat > "$MONITORS_CONF" << 'EOF'
# Monitor Configuration

# Laptop display - 2K@165Hz
monitor = eDP-2, 2560x1440@165, 0x0, 1.0

# External monitor - Mirror mode (duplicates eDP-2)
monitor = HDMI-A-1, preferred, 0x0, 1, mirror, eDP-2

# Fallback for any other monitors
monitor = , preferred, auto, 1
EOF
    hyprctl reload
    notify-send "Display Mode" "Mirroring" -t 2000
fi

# Signal waybar to update
pkill -RTMIN+11 waybar 2>/dev/null || true
