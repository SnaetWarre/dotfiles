#!/bin/bash
# ── cycle-kbd-brightness.sh ───────────────────────────────────────
# Description: Cycle through keyboard backlight brightness levels
# Usage: Called by Waybar `custom/kbd-brightness` on-click
# Dependencies: asusctl
# ──────────────────────────────────────────────────────────

# Cycle to next brightness level using asusctl built-in command
asusctl leds next
