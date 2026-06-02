#!/bin/bash
# ── gamemode.sh ───────────────────────────────────────────
# Description: Toggle game mode - sets Performance profile, disables effects
# Usage: Called by Hyprland keybind (Super + G)
# Dependencies: asusctl, hyprctl, notify-send
# ──────────────────────────────────────────────────────────

STATE_FILE="/tmp/gamemode_state"
TOFI_CMD='tofi-drun --config ~/.config/hypr/tofi-drun.conf'

notify() {
    notify-send -u normal -t 3000 "Game Mode" "$1"
}

enable_gamemode() {
    # Save current profile before switching
    current_profile=$(asusctl profile get | awk '/Active profile/ {print $NF}')
    echo "$current_profile" > "$STATE_FILE"

    # Set to Performance mode (Reactor ON)
    asusctl profile set Performance

    # Unbind tofi (CTRL + SPACE)
    hyprctl keyword unbind "CTRL, SPACE"

    # Disable blur for performance
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:shadow:enabled false

    # Disable opacity (set to 1.0)
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0

    # Disable animations (Hyprland 0.52+ syntax)
    hyprctl keyword animations:enabled false

    notify "Game Mode ON (effects already retro-flat)"
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

    # Rebind tofi (CTRL + SPACE)
    hyprctl keyword bindd "CTRL, SPACE, Runs your application launcher, exec, $TOFI_CMD"

    # Restore the retro baseline rather than the previous modern effects.
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:shadow:enabled false

    # Restore opacity
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0

    # Keep animations disabled for the retro baseline.
    hyprctl keyword animations:enabled false

    notify "Game Mode OFF (retro baseline restored)"
}

# Toggle based on state file existence
if [ -f "$STATE_FILE" ]; then
    disable_gamemode
else
    enable_gamemode
fi
