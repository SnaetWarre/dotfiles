#!/bin/bash

# Get WiFi info in one command
wifi_info=$(nmcli -t -f active,ssid,signal dev wifi | grep '^yes')

if [[ -z "$wifi_info" ]]; then
    echo '{"icon": "", "ssid": "Disconnected", "strength": 0}'
    exit 0
fi

# Parse the single line output
IFS=':' read -r active ssid signal <<< "$wifi_info"

# Convert SSID to uppercase once
ssid_upper="${ssid^^}"
icon=" "

echo "{\"icon\": \"$icon\", \"ssid\": \"$ssid_upper\", \"strength\": $signal}"
