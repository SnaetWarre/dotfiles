#!/bin/bash

# Get pywal colors
COLOR_0=$(sed -n '1p' ~/.cache/wal/colors)  # Background
COLOR_1=$(sed -n '2p' ~/.cache/wal/colors)  # Dark accent
COLOR_2=$(sed -n '3p' ~/.cache/wal/colors)  # Light accent
COLOR_3=$(sed -n '4p' ~/.cache/wal/colors)  # Red
COLOR_4=$(sed -n '5p' ~/.cache/wal/colors)  # Orange
COLOR_5=$(sed -n '6p' ~/.cache/wal/colors)  # Yellow/Green
COLOR_6=$(sed -n '7p' ~/.cache/wal/colors)  # Light
COLOR_7=$(sed -n '8p' ~/.cache/wal/colors)  # Foreground
COLOR_8=$(sed -n '9p' ~/.cache/wal/colors)  # Gray

# Function to convert hex to rgb
hex_to_rgb() {
    hex=$1
    r=$((16#${hex:1:2}))
    g=$((16#${hex:3:2}))
    b=$((16#${hex:5:2}))
    echo "$r, $g, $b"
}

# Get RGB values
COLOR_2_RGB=$(hex_to_rgb "$COLOR_2")
COLOR_7_RGB=$(hex_to_rgb "$COLOR_7")
BG_RGB=$(hex_to_rgb "$COLOR_0")

# Create wlogout style with pywal colors
cat > ~/.config/wlogout/style.css << EOF
* {
    background-image: none;
    box-shadow: none;
}

window {
    background-color: rgba(${BG_RGB}, 0.9);
}

button {
    border-radius: 8px;
    border-color: rgba(${COLOR_2_RGB}, 0.4);
    text-decoration-color: rgb(${COLOR_7_RGB});
    color: rgb(${COLOR_7_RGB});
    background-color: rgba(${BG_RGB}, 0.7);
    border-style: solid;
    border-width: 2px;
    background-repeat: no-repeat;
    background-position: center;
    background-size: 25%;
    margin: 5px;
    transition: all 0.15s ease-in-out;
}

button:focus, button:active, button:hover {
    background-color: rgba(${COLOR_2_RGB}, 0.7);
    border-color: rgba(${COLOR_2_RGB}, 0.8);
    outline-style: none;
}

#lock {
    background-image: image(url("/usr/share/wlogout/assets/lock.svg"), url("/usr/local/share/wlogout/assets/lock.png"));
}

#logout {
    background-image: image(url("/usr/share/wlogout/assets/logout.svg"), url("/usr/local/share/wlogout/icons/logout.png"));
}

#suspend {
    background-image: image(url("/usr/share/wlogout/assets/suspend.svg"), url("/usr/local/share/wlogout/icons/suspend.png"));
}

#hibernate {
    background-image: image(url("/usr/share/wlogout/assets/hibernate.svg"), url("/usr/local/share/wlogout/icons/hibernate.png"));
}

#shutdown {
    background-image: image(url("/usr/share/wlogout/assets/shutdown.svg"), url("/usr/local/share/wlogout/icons/shutdown.png"));
}

#reboot {
    background-image: image(url("/usr/share/wlogout/assets/reboot.svg"), url("/usr/local/share/wlogout/icons/reboot.png"));
}
EOF

# Now let's create a directory for our custom SVGs and update their colors
mkdir -p ~/.config/wlogout/icons

# Function to update SVG colors
update_svg() {
    local src="$1"
    local dest="$2"
    if [ -f "$src" ]; then
        # Replace black with our accent color and preserve transparency
        sed "s/#000000/${COLOR_2}/g; s/#000/${COLOR_2}/g; s/black/${COLOR_2}/g" "$src" > "$dest"
    fi
}

# Update all SVGs
for icon in lock logout suspend hibernate shutdown reboot; do
    update_svg "/usr/share/wlogout/assets/${icon}.svg" "$HOME/.config/wlogout/icons/${icon}.svg"
done 