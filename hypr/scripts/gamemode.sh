#!/bin/bash
# ── gamemode.sh ───────────────────────────────────────────
# Description: Toggle game mode - sets Performance profile and unbinds rofi
# Usage: Called by Hyprland keybind (Super + G)
# Dependencies: asusctl, hyprctl, notify-send
# ──────────────────────────────────────────────────────────

STATE_FILE="/tmp/gamemode_state"
ROFI_CMD='rofi -show combi -modi drun,run,combi -combi-modi drun,run -combi-hide-mode-prefix true -theme ~/.config/rofi/config.rasi'

notify() {
    notify-send -u normal -t 3000 "Game Mode" "$1"
}

enable_gamemode() {
    # Save current profile before switching
    current_profile=$(asusctl profile -p | awk '/Active profile/ {print $NF}')
    echo "$current_profile" > "$STATE_FILE"

    # Set to Performance mode (Reactor ON)
    asusctl profile -P Performance

    # Unbind rofi (CTRL + SPACE)
    hyprctl keyword unbind "CTRL, SPACE"

    notify "🎮 Game Mode ON"
}

disable_gamemode() {
    # Restore previous profile
    if [ -f "$STATE_FILE" ]; then
        previous_profile=$(cat "$STATE_FILE")
        asusctl profile -P "$previous_profile"
        rm -f "$STATE_FILE"
    else
        # Fallback to Balanced if no saved state
        asusctl profile -P Balanced
    fi

    # Rebind rofi (CTRL + SPACE)
    hyprctl keyword bindd "CTRL, SPACE, Runs your application launcher, exec, $ROFI_CMD"

    notify "🎮 Game Mode OFF"
}

# Toggle based on state file existence
if [ -f "$STATE_FILE" ]; then
    disable_gamemode
else
    enable_gamemode
fi
