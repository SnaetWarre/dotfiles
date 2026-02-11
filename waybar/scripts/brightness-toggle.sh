#!/bin/bash
# ── brightness-toggle.sh ─────────────────────────────
# Description: Cycle screen brightness 0%–100% in steps of 10%
# Usage: Waybar `custom/brightness` on-click
# Dependencies: brightnessctl
# ─────────────────────────────────────────────────────

STATE_FILE="/tmp/brightness-step"
STEPS=(0 10 20 30 40 50 60 70 80 90 100)

# Read current index; default to 10 (100%) if no state file
if [ -f "$STATE_FILE" ]; then
	idx=$(cat "$STATE_FILE")
else
	idx=10
fi

# Advance to next step, wrap back to 0
idx=$(( (idx + 1) % ${#STEPS[@]} ))

echo "$idx" > "$STATE_FILE"
brightnessctl set "${STEPS[$idx]}%"
