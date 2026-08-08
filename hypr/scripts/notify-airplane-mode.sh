#!/usr/bin/env bash
set -euo pipefail

# The kernel's rfkill input handler owns the ASUS airplane-mode key.
# Wait for it to finish toggling, then report the resulting hardware state.
sleep 0.25

radio_state="$(rfkill -rn -o TYPE,SOFT)"

if ! grep -q '[^[:space:]]' <<<"$radio_state"; then
    title="Airplane mode"
    message="No radio transmitters detected"
elif awk '$2 != "blocked" { exit 1 }' <<<"$radio_state"; then
    title="Airplane mode: On"
    message="All available radio transmitters are blocked"
elif awk '$2 != "unblocked" { exit 1 }' <<<"$radio_state"; then
    title="Airplane mode: Off"
    message="Available radio transmitters restored"
else
    title="Airplane mode: Custom"
    message="Some radios are enabled and some are blocked"
fi

notify-send \
    --app-name="Laptop hotkeys" \
    --replace-id=9912 \
    "$title" \
    "$message"
