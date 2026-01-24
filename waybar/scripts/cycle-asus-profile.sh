#!/bin/bash
# ── cycle-asus-profile.sh ───────────────────────────────────────  
# Description: Cycle through ASUS power profiles
# Usage: Called by Waybar `custom/asus-profile` on-click
# Dependencies: asusctl
# ──────────────────────────────────────────────────────────  

# Cycle to next profile using asusctl built-in command
asusctl profile next
