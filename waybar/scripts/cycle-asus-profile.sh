#!/bin/bash
# ── cycle-asus-profile.sh ───────────────────────────────────────  
# Description: Cycle through ASUS power profiles
# Usage: Called by Waybar `custom/asus-profile` on-click
# Dependencies: asusctl
# ──────────────────────────────────────────────────────────  

# Get current profile
current=$(asusctl profile -p | awk '/Active profile/ {print $NF}')

# Cycle through profiles: Balanced -> Performance -> LowPower -> Balanced
case "$current" in
  Balanced)
    asusctl profile -P Performance
    ;;
  Performance)
    asusctl profile -P LowPower
    ;;
  LowPower|Quiet)
    asusctl profile -P Balanced
    ;;
  *)
    # Default to Balanced if unknown
    asusctl profile -P Balanced
    ;;
esac
