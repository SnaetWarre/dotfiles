#!/usr/bin/env bash
set -euo pipefail

asusctl aura effect --next-mode

notify-send \
    --app-name="Laptop hotkeys" \
    --replace-id=9914 \
    "ASUS Aura" \
    "Lighting effect changed"

