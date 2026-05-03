#!/usr/bin/env bash

# Battery thresholds
THRESHOLD_20=20
THRESHOLD_10=10
POLL_INTERVAL=300

# Log file
LOG_FILE="$HOME/.cache/battery-notify.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

find_upower_battery() {
    upower -e 2>/dev/null | grep -m1 '/battery_BAT'
}

find_sysfs_battery() {
    find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -print -quit 2>/dev/null
}

get_upower_property() {
    local path=$1
    local interface="org.freedesktop.UPower.Device"
    local property=$2

    busctl get-property org.freedesktop.UPower "$path" "$interface" "$property" 2>/dev/null | awk '{print $2}'
}

get_battery_percentage() {
    if [ -n "$UPOWER_BATTERY" ]; then
        get_upower_property "$UPOWER_BATTERY" Percentage | awk '{printf "%d\n", $1}'
        return
    fi

    if [ -n "$SYSFS_BATTERY" ] && [ -f "$SYSFS_BATTERY/capacity" ]; then
        cat "$SYSFS_BATTERY/capacity"
        return
    fi

    echo "100"
}

is_discharging() {
    local status state

    if [ -n "$UPOWER_BATTERY" ]; then
        state=$(get_upower_property "$UPOWER_BATTERY" State)
        [ "$state" = "2" ] && return 0
        return 1
    fi

    if [ -n "$SYSFS_BATTERY" ] && [ -f "$SYSFS_BATTERY/status" ]; then
        status=$(cat "$SYSFS_BATTERY/status")
        [ "$status" = "Discharging" ] && return 0
        return 1
    fi

    return 1
}

send_notification() {
    local level=$1
    local message=$2
    
    log "Sending notification: $level - $message"
    if ! notify-send -u critical "$level" "$message"; then
        log "Failed to send notification"
    fi
}

# Variables to track if notifications have been sent
sent_20=false
sent_10=false

check_battery() {
    battery_percentage=$(get_battery_percentage)

    if is_discharging; then
        if [ "$battery_percentage" -le "$THRESHOLD_10" ] && [ "$sent_10" = "false" ]; then
            send_notification "Battery Critical" "Battery 10%, plug it in you dumb fuck ffs"
            sent_10=true
            sent_20=true  # Prevent 20% notification after 10%
        elif [ "$battery_percentage" -le "$THRESHOLD_20" ] && [ "$sent_20" = "false" ]; then
            send_notification "Battery Low" "Battery 20%, grab ya charger mate"
            sent_20=true
        elif [ "$battery_percentage" -gt "$THRESHOLD_20" ]; then
            sent_20=false
            sent_10=false
        fi
    else
        # Reset flags when charging
        sent_20=false
        sent_10=false
    fi
}

UPOWER_BATTERY=$(find_upower_battery)
SYSFS_BATTERY=$(find_sysfs_battery)

log "Starting battery notification script"
log "UPower battery: ${UPOWER_BATTERY:-none}; sysfs battery: ${SYSFS_BATTERY:-none}"

check_battery

if [ -n "$UPOWER_BATTERY" ] && command -v upower >/dev/null 2>&1 && command -v busctl >/dev/null 2>&1; then
    upower --monitor | while read -r event; do
        case "$event" in
            *"$UPOWER_BATTERY"*|*"line_power"*)
                check_battery
                ;;
        esac
    done
fi

log "UPower monitor unavailable, falling back to ${POLL_INTERVAL}s polling"
while true; do
    check_battery
    sleep "$POLL_INTERVAL"
done
