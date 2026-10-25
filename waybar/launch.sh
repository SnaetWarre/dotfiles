#!/bin/sh
# Start Waybar with the workspaces module that matches the running compositor.
# Hyprland uses the config as-is. Mango has no Hyprland IPC, so a copy with
# ext/workspaces in place of hyprland/workspaces is written to the runtime dir.

if pgrep -u "$(id -u)" -x mango >/dev/null; then
    runtime_config="${XDG_RUNTIME_DIR:-/tmp}/waybar/config"
    mkdir -p "$(dirname "$runtime_config")"
    sed 's|"hyprland/workspaces",|"ext/workspaces",|' "$HOME/.config/waybar/config" > "$runtime_config"
    exec waybar -c "$runtime_config" -s "$HOME/.config/waybar/style.css"
fi

exec waybar
