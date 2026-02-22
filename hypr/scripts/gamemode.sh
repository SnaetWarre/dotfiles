#!/bin/bash
# ── gamemode.sh ───────────────────────────────────────────
# Description: Toggle game mode - sets Performance profile, disables effects
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
    current_profile=$(asusctl profile get | awk '/Active profile/ {print $NF}')
    echo "$current_profile" > "$STATE_FILE"

    # Set to Performance mode (Reactor ON)
    asusctl profile set Performance

    # Unbind rofi (CTRL + SPACE)
    hyprctl keyword unbind "CTRL, SPACE"

    # Disable blur for performance
    hyprctl keyword decoration:blur:enabled false

    # Disable opacity (set to 1.0)
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0

    # Disable animations (Hyprland 0.52+ syntax)
    hyprctl keyword animations:enabled false

    notify "🎮 Game Mode ON (Effects disabled)"
}

disable_gamemode() {
    # Restore previous profile
    if [ -f "$STATE_FILE" ]; then
        previous_profile=$(cat "$STATE_FILE")
        asusctl profile set "$previous_profile"
        rm -f "$STATE_FILE"
    else
        # Fallback to Balanced if no saved state
        asusctl profile set Balanced
    fi

    # Rebind rofi (CTRL + SPACE)
    hyprctl keyword bindd "CTRL, SPACE, Runs your application launcher, exec, $ROFI_CMD"

    # Re-enable blur
    hyprctl keyword decoration:blur:enabled true

    # Restore opacity
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 0.85

    # Re-enable animations
    hyprctl keyword animations:enabled no

    notify "🎮 Game Mode OFF (Effects restored)"
}

# Toggle based on state file existence
if [ -f "$STATE_FILE" ]; then
    disable_gamemode
else
    enable_gamemode
fi
