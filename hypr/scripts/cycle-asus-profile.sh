#!/usr/bin/env bash
set -euo pipefail

asusctl profile next
profile="$(asusctl profile get | awk '/Active profile/ { print $NF; exit }')"

notify-send \
    --app-name="Laptop hotkeys" \
    --replace-id=9913 \
    "ASUS fan profile" \
    "${profile:-Changed}"

