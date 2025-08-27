#!/bin/bash

ws() {
    # Single hyprctl call to get all workspace data
    workspace_data=$(hyprctl workspaces -j)
    current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
    
    # Parse all workspace data in one jq call
    workspace_info=$(echo "$workspace_data" | jq -r '.[] | "\(.id) \(.windows)"')
    
    # Create arrays for workspace states
    declare -A workspace_windows
    while read -r id windows; do
        workspace_windows[$id]=$windows
    done <<< "$workspace_info"
    
    # Build output efficiently
    output="(box :class \"ws\" :halign \"end\" :orientation \"h\" :spacing 8 :space-evenly \"false\""
    
    for i in {1..5}; do
        windows=${workspace_windows[$i]:-0}
        
        if [[ "$current_workspace" == "$i" ]]; then
            icon="●"
            class="visiting"
        elif [[ "$windows" -gt 0 ]]; then
            icon="○"
            class="occupied"
        else
            icon="○"
            class="free"
        fi
        
        output+=" (eventbox :onclick \"hyprctl dispatch workspace $i\" :cursor \"pointer\" :class \"$class\" (label :text \"$icon\"))"
    done
    
    output+=")"
    echo "$output"
}

# Initial output
ws

# Get socket path once
HYPRLAND_SIGNATURE_ACTUAL=$(ls -td /run/user/1000/hypr/*/ | head -n1 | xargs basename)
SOCKET="/run/user/1000/hypr/${HYPRLAND_SIGNATURE_ACTUAL}/.socket2.sock"

# Listen for workspace events
stdbuf -oL socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
    case $line in
        "workspace>>"*|"createworkspace>>"*|"destroyworkspace>>"*)
            ws
            ;;
    esac
done
