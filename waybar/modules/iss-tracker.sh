#!/bin/bash

API_URL="http://api.open-notify.org/iss-now.json"
RESPONSE=$(curl -s "$API_URL")

# Check if response is valid JSON and contains 'iss_position'
if ! echo "$RESPONSE" | jq . >/dev/null 2>&1; then
    echo '{"text": "-", "tooltip": "ISS API unavailable", "class": "none"}'
    exit 0
fi

SUCCESS=$(echo "$RESPONSE" | jq -r '.message')
if [ "$SUCCESS" != "success" ]; then
    echo '{"text": "-", "tooltip": "No ISS data available", "class": "none"}'
    exit 0
fi

LAT=$(echo "$RESPONSE" | jq -r '.iss_position.latitude')
LON=$(echo "$RESPONSE" | jq -r '.iss_position.longitude')
TIME=$(echo "$RESPONSE" | jq -r '.timestamp')

# Format time
FORMATTED_TIME=$(date -d "@$TIME" '+%Y-%m-%d %H:%M:%S')

# Show a rocket and coordinates
TEXT="[$LAT, $LON]"
TOOLTIP="ISS position at $FORMATTED_TIME\\nLatitude: $LAT\\nLongitude: $LON\\nClick for live map!"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"normal\"}"