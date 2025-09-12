#!/bin/bash

get_icon(){
  case $1 in
    9[0-9]|100)
      CLASS="BAT1"
      ICON=""
      ;;
    8[0-9]|7[0-9]|6[5-9])
      CLASS="BAT2"
      ICON=""
      ;;
    6[0-4]|5[0-9]|4[5-9])
      CLASS="BAT3"
      ICON=""
      ;;
    4[0-4]|3[0-9]|2[0-9]|1[5-9])
      CLASS="BAT4"
      ICON=""
      ;;
    *)
      CLASS="BAT5"
      ICON=""
      ;;
  esac
}

while true; do
    # Read all battery data in one pass
    CHARGE_NOW=$(cat /sys/class/power_supply/BAT0/charge_now)
    CURRENT_NOW=$(cat /sys/class/power_supply/BAT0/current_now)
    CURRENT_NOW=${CURRENT_NOW#-}
    CHARGE_FULL=$(cat /sys/class/power_supply/BAT0/charge_full)
    STATUS=$(cat /sys/class/power_supply/BAT0/status)
    BATTERY=$(cat /sys/class/power_supply/BAT0/capacity)

    # Get icon and class
    get_icon "$BATTERY"
    if [[ "$STATUS" == "Charging" ]]; then
        CLASS="CHARGING"
    fi

    # Calculate time estimate
    if [ "$CURRENT_NOW" -ne 0 ]; then
        if [[ "$STATUS" == "Discharging" ]]; then
            MINUTES_LEFT=$(( CHARGE_NOW * 60 / CURRENT_NOW ))
            HOURS=$(( MINUTES_LEFT / 60 ))
            MINS=$(( MINUTES_LEFT % 60 ))
            TIME_EST="$HOURS h $MINS min left, $STATUS"
        elif [[ "$STATUS" == "Charging" ]]; then
            DIFF=$(( CHARGE_FULL - CHARGE_NOW ))
            MINUTES_TO_FULL=$(( DIFF * 60 / CURRENT_NOW ))
            HOURS=$(( MINUTES_TO_FULL / 60 ))
            MINS=$(( MINUTES_TO_FULL % 60 ))
            TIME_EST="$HOURS h $MINS min to full, $STATUS"
        else
            TIME_EST="0 h 0 min to full, $STATUS"
        fi
    else
        TIME_EST="Calculating..., $STATUS"
    fi

    # Output JSON with both status and icon
    jq -n -c \
        --arg status "$TIME_EST" \
        --arg icon "(box :class \"$CLASS\" \"$ICON\")" \
        '{status: $status, icon: $icon}'

    sleep 1
done
