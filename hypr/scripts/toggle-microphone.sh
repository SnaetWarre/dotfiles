#!/usr/bin/env bash
set -euo pipefail

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
state="$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)"

if [[ "$state" == *MUTED* ]]; then
    message="Muted"
else
    message="Unmuted"
fi

notify-send \
    --app-name="Laptop hotkeys" \
    --replace-id=9911 \
    "Microphone" \
    "$message"

