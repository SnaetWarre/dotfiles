#!/bin/bash
base_dir="$HOME/.config/eww/"
image_file="${base_dir}image.jpg"
cover_file="${base_dir}scripts/cover.png"

# Create directory once
mkdir -p "$base_dir"

# Cache for downloaded images to avoid unnecessary downloads
declare -A image_cache

playerctl metadata -F -f '{{playerName}}|{{title}}|{{artist}}|{{mpris:artUrl}}|{{status}}|{{mpris:length}}' | while IFS='|' read -r name title artist artUrl status length; do
    # Calculate length once
    if [[ -n "$length" && "$length" =~ ^[0-9]+$ ]]; then
        len_sec=$(( (length + 500000) / 1000000 ))
        mins=$((len_sec / 60))
        secs=$((len_sec % 60))
        lengthStr=$(printf "%d:%02d" "$mins" "$secs")
    else
        len_sec=""
        lengthStr=""
    fi
    
    # Handle album art more efficiently
    if [[ "$artUrl" =~ ^https?:// ]]; then
        # Check if we already have this image cached
        if [[ -z "${image_cache[$artUrl]}" ]]; then
            tmp_image="${image_file}.tmp"
            if wget -q -O "$tmp_image" "$artUrl" 2>/dev/null; then
                mv "$tmp_image" "$image_file"
                image_cache[$artUrl]=1
            else
                rm -f "$tmp_image"
                cp "$cover_file" "$image_file"
            fi
        fi
    else
        # Use default cover if no URL
        if [[ ! -f "$image_file" ]] || [[ "$(stat -c %Y "$image_file" 2>/dev/null)" -lt "$(stat -c %Y "$cover_file" 2>/dev/null)" ]]; then
            cp "$cover_file" "$image_file"
        fi
    fi
    
    # Output JSON
    jq -n -c \
        --arg name "$name" \
        --arg title "$title" \
        --arg artist "$artist" \
        --arg artUrl "$image_file" \
        --arg status "$status" \
        --arg length "$len_sec" \
        --arg lengthStr "$lengthStr" \
        '{name: $name, title: $title, artist: $artist, thumbnail: $artUrl, status: $status, length: $length, lengthStr: $lengthStr}'
done
