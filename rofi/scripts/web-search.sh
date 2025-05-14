#!/bin/bash

# List of search engines
declare -A search_engines
search_engines=(
    ["google"]="https://www.google.com/search?q="
    ["youtube"]="https://www.youtube.com/results?search_query="
    ["github"]="https://github.com/search?q="
    ["duckduckgo"]="https://duckduckgo.com/?q="
)

# Get the search engine and query from Rofi
selected=$(printf '%s\n' "${!search_engines[@]}" | rofi -dmenu -theme ~/.config/rofi/config.rasi -p "Search Engine:")
if [ -z "$selected" ]; then
    exit 0
fi

query=$(rofi -dmenu -theme ~/.config/rofi/config.rasi -p "Search Query:")
if [ -z "$query" ]; then
    exit 0
fi

# URL encode the query
encoded_query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")

# Open the browser with the search URL
firefox "${search_engines[$selected]}$encoded_query" 