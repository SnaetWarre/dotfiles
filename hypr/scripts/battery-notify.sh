#!/bin/bash

# Battery thresholds
THRESHOLD_20=20
THRESHOLD_10=10

# Log file
LOG_FILE="$HOME/.cache/battery-notify.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to get battery percentage
get_battery_percentage() {
    if [ -f /sys/class/power_supply/BAT0/capacity ]; then
        cat /sys/class/power_supply/BAT0/capacity
    else
        log "No battery found, assuming 100%"
        echo "100"
    fi
}

# Function to check if battery is charging
is_charging() {
    if [ -f /sys/class/power_supply/BAT0/status ]; then
        status=$(cat /sys/class/power_supply/BAT0/status)
        log "Battery status: $status"
        [ "$status" = "Charging" ] && echo "true" || echo "false"
    else
        log "No battery status found, assuming charging"
        echo "true"
    fi
}

# Function to send notification
send_notification() {
    local level=$1
    local message=$2
    
    log "Sending notification: $level - $message"
    if ! notify-send -u critical "$level" "$message"; then
        log "Failed to send notification"
    fi
}

log "Starting battery notification script"

# Variables to track if notifications have been sent
sent_20=false
sent_10=false

# Main loop
while true; do
    battery_percentage=$(get_battery_percentage)
    charging=$(is_charging)
    
    log "Battery: $battery_percentage%, Charging: $charging"

    if [ "$charging" = "false" ]; then
        if [ "$battery_percentage" -eq "$THRESHOLD_10" ] && [ "$sent_10" = "false" ]; then
            send_notification "Battery Critical" "Battery 10%, plug it in you dumb fuck ffs"
            sent_10=true
            sent_20=true  # Prevent 20% notification after 10%
        elif [ "$battery_percentage" -eq "$THRESHOLD_20" ] && [ "$sent_20" = "false" ]; then
            send_notification "Battery Low" "Battery 20%, grab ya charger mate"
            sent_20=true
        elif [ "$battery_percentage" -gt "$THRESHOLD_20" ]; then
            # Reset flags when battery is above thresholds
            sent_20=false
            sent_10=false
        fi
    else
        # Reset flags when charging
        sent_20=false
        sent_10=false
    fi

    # Check once in a while
    sleep 100
done
