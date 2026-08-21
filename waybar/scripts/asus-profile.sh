#!/bin/bash
# ── asus-profile.sh ───────────────────────────────────────
# Description: Display current ASUS power profile with color
# Usage: Called by Waybar `custom/asus-profile`
# Dependencies: asusctl, awk
# ──────────────────────────────────────────────────────────

# Load wal/pywal colors from colors file
if [ -f "$HOME/.cache/wal/colors" ]; then
    # Read colors file (16 colors, indexed 0-15)
    color_index=0
    while IFS= read -r color || [ -n "$color" ]; do
        color="${color#\#}"
        color="#${color}"
        eval "color${color_index}=${color}"
        color_index=$((color_index + 1))
        [ $color_index -ge 16 ] && break
    done < "$HOME/.cache/wal/colors"
    color_red="${color1:-#bf616a}"
    color_orange="${color3:-#fab387}"
    color_cyan="${color6:-#56b6c2}"
    color_fg="${color7:-#ffffff}"
else
    # Fallback to dionysus colors
    color_red="#bf616a"
    color_orange="#fab387"
    color_cyan="#56b6c2"
    color_fg="#ffffff"
fi

print_asus_profile() {
    local active_profile profile_label profile_color

    active_profile=$(asusctl profile get 2>/dev/null | awk '/Active profile/ {print $NF}')

    if [ -z "$active_profile" ]; then
        printf "<span foreground='%s'>ASUS N/A</span>\n" "$color_fg"
        return
    fi

    case "$active_profile" in
        Performance)
            profile_label="REACTOR ON"
            profile_color="$color_red"
            ;;
        Balanced)
            profile_label="STABILIZATION"
            profile_color="$color_orange"
            ;;
        Quiet|LowPower)
            profile_label="REACTOR OFF"
            profile_color="$color_cyan"
            ;;
        *)
            profile_label="ASUS ??"
            profile_color="$color_fg"
            ;;
    esac

    printf "<span foreground='%s'>%s</span>\n" "$profile_color" "$profile_label"
}

print_asus_profile

if [ "${1:-}" = "--watch" ]; then
    while IFS= read -r asusd_event; do
        case "$asusd_event" in
            *PlatformProfile*) print_asus_profile ;;
        esac
    done < <(
        gdbus monitor --system \
            --dest xyz.ljones.Asusd \
            --object-path /xyz/ljones 2>/dev/null
    )
fi
