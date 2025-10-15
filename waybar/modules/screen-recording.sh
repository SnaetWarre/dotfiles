#!/bin/bash

if pgrep -x wl-screenrec >/dev/null || pgrep -x wf-recorder >/dev/null; then
  echo '{"text": "󰻂", "tooltip": "Stop recording", "class": "recording"}'
else
  echo '{"text": "󰑊", "tooltip": "Start recording", "class": "idle"}'
fi