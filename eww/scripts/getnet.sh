#!/bin/bash

# Get all connections in one call
declare -A SEEN
declare -A AUTO

# Read all connections at once
while IFS= read -r conn_name; do
    [[ -z "$conn_name" ]] && continue
    
    # Get SSID and autoconnect in one nmcli call
    ssid=$(nmcli -g 802-11-wireless.ssid connection show "$conn_name" 2>/dev/null)
    autoconnect=$(nmcli -g connection.autoconnect connection show "$conn_name" 2>/dev/null)
    
    if [[ -n "$ssid" ]]; then 
        AUTO["$ssid"]=$autoconnect
    fi
done < <(nmcli -t -f NAME connection show)

# Get WiFi list in one call
wifi_list=()
while IFS=: read -r inuse ssid; do
    [[ -z "$ssid" ]] && continue
    
    # Skip if already seen
    if [[ -n "${SEEN[$ssid]}" ]]; then
        continue
    fi
    SEEN["$ssid"]=1

    # Determine status
    in_use=false
    [[ "$inuse" == "*" ]] && in_use=true

    autoconnect=false
    [[ -n "${AUTO[$ssid]}" && "${AUTO[$ssid]}" == "yes" ]] && autoconnect=true

    # Create JSON object
    wifi_json=$(jq -nc \
        --arg ssid "$ssid" \
        --argjson in_use "$in_use" \
        --argjson autoconnect "$autoconnect" \
        '{
          ssid: $ssid,
          in_use: $in_use,
          autoconnect: $autoconnect
        }')

    wifi_list+=("$wifi_json")
done < <(nmcli -t -f IN-USE,SSID dev wifi list)

# Output final JSON array
jq -nc --argjson arr "$(printf '[%s]' "$(IFS=,; echo "${wifi_list[*]}")")" '$arr'
