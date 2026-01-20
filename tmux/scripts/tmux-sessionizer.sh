#!/usr/bin/env bash
# Wrapper script that handles the popup and switch-client separately

TMUX_SESSION_FILE="/tmp/tmux-sessionizer-target"

# Clean up any previous selection
rm -f "$TMUX_SESSION_FILE"

# Run the selector in a popup - this blocks until popup closes
tmux display-popup -E -h 80% -w 80% ~/.config/tmux/scripts/tmux-sessionizer-picker.sh

# After popup closes, check if a session was selected
if [[ -f "$TMUX_SESSION_FILE" ]]; then
    target=$(cat "$TMUX_SESSION_FILE")
    rm -f "$TMUX_SESSION_FILE"
    if [[ -n "$target" ]]; then
        tmux switch-client -t "$target"
    fi
fi
