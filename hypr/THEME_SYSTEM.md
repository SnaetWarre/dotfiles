# Hyprland + Pywal Theme System Documentation

## Overview
This system provides dynamic theme switching using Pywal to generate colors from wallpapers, then applies those colors across the entire desktop environment including Hyprland, Waybar, Rofi, Swaync, and other components.

## Core Components

### 1. Main Theme Scripts

#### `wallpaper.sh` - Primary Theme Switcher
- **Location**: `~/.config/hypr/scripts/wallpaper.sh`
- **Purpose**: Main entry point for theme switching
- **Functionality**:
  - Accepts optional wallpaper path as argument
  - Randomly selects wallpaper from `~/Pictures/wallpapers/` if no argument
  - Runs `wal -i` to generate colors from wallpaper
  - Calls `apply_wal_outputs.sh` to distribute colors
  - Updates wlogout colors separately
  - Sets wallpaper with `swww img`
  - Reloads Waybar with `killall -SIGUSR2 waybar`

#### `apply_wal_outputs.sh` - Color Distribution Engine
- **Location**: `~/.config/hypr/scripts/apply_wal_outputs.sh`
- **Purpose**: Distributes Pywal colors to all applications
- **Processes**:
  - Sources colors from `~/.cache/wal/colors.sh`
  - Converts hex colors to RGB format
  - Uses `envsubst` to replace variables in templates
  - Generates/updates files for:
    - Waybar CSS (`~/.config/waybar/style.css`)
    - Swaync CSS (`~/.config/swaync/style.css`)
    - Wlogout CSS (`~/.config/wlogout/style.css`)
    - Swaylock config (`~/.config/swaylock/config`)
    - Ghostty config (`~/.config/ghostty/config`)
    - Rofi colors (`~/.config/rofi/colors.rasi`)
    - Rofi wallpaper theme (`~/.config/rofi/wallpaper.rasi`)
    - eww CSS (`~/.config/eww/eww.scss`)
    - Zed theme (via separate script)
    - Perplexity SVG icon
  - Restarts services (eww, swaync)
  - Updates Firefox with `pywalfox update`
  - Sets keyboard color with `rogauracore`

#### `wallpaper-select.sh` - GUI Wallpaper Selector
- **Location**: `~/.config/hypr/scripts/wallpaper-select.sh`
- **Purpose**: Provides GUI for wallpaper selection
- **Functionality**:
  - Scans `~/Pictures/wallpapers/` for images
  - Creates Rofi menu with image previews
  - Calls `wallpaper.sh` with selected wallpaper

### 2. Hyprland Configuration

#### Main Config (`hyprland.conf`)
- **Keybinds**:
  - `SUPER + W`: Run wallpaper script (random)
  - `SUPER + SHIFT + W`: Open wallpaper selector
- **Autostart**:
  - `swww-daemon` for wallpaper management
  - `swaync` for notifications
  - `eww` for widgets
  - Battery notification script
- **Window Rules**:
  - Floating windows for various apps
  - Opacity settings for specific apps
  - Rounding for terminal windows

#### Monitor Configuration (`monitors.conf`)
- **Laptop**: `eDP-2, 2560x1440@165, 0x0, 1.0`
- **External**: `HDMI-A-1, 1920x1080@60, -1920x0, 1.0`

#### Workspace Configuration (`workspaces.conf`)
- Workspaces 1,2,4,5,6,7,8,9,10: Laptop monitor
- Workspace 3: External monitor

### 3. Template System

#### Template Files (`.template` extension)
- **Waybar**: `~/.config/waybar/style.css.template`
- **Swaync**: `~/.config/swaync/style.css.template`
- **Wlogout**: `~/.config/wlogout/style.css.template`
- **Swaylock**: `~/.config/swaylock/config.template`
- **Ghostty**: `~/.config/ghostty/config.template`
- **Rofi**: `~/.config/rofi/wallpaper.rasi.template`
- **eww**: `~/.config/eww/eww.scss.template`

#### Variable Replacement
Uses `envsubst` with these color variables:
- `color0` through `color15`: Hex colors
- `color0_rgb` through `color15_rgb`: RGB format
- `wallpaper`: Path to current wallpaper

### 4. Color Generation Process

1. **Pywal Generation**: `wal -i wallpaper.jpg` creates:
   - `~/.cache/wal/colors.sh` (shell variables)
   - `~/.cache/wal/colors-*.json` (JSON formats)
   - `~/.cache/wal/wallpaper` (current wallpaper path)

2. **Color Distribution**: `apply_wal_outputs.sh`:
   - Sources `colors.sh`
   - Converts hex to RGB
   - Replaces variables in templates
   - Generates final config files

### 5. Service Integration

#### Waybar
- Template: `~/.config/waybar/style.css.template`
- Output: `~/.config/waybar/style.css`
- Reload: `killall -SIGUSR2 waybar`

#### Swaync (Notifications)
- Template: `~/.config/swaync/style.css.template`
- Output: `~/.config/swaync/style.css`
- Reload: `swaync-client -rs`

#### eww (Widgets)
- Template: `~/.config/eww/eww.scss.template`
- Output: `~/.config/eww/eww.scss`
- Reload: `eww reload`

#### Rofi
- Colors: `~/.config/rofi/colors.rasi`
- Wallpaper theme: `~/.config/rofi/wallpaper.rasi`
- Used by: `$applauncher` variable in Hyprland config

#### Swaylock (Screen Lock)
- Template: `~/.config/swaylock/config.template`
- Output: `~/.config/swaylock/config`
- Uses wallpaper as background

#### Wlogout (Logout Menu)
- Template: `~/.config/wlogout/style.css.template`
- Output: `~/.config/wlogout/style.css`
- Icons: Generated in `~/.config/wlogout/icons/`

#### Ghostty (Terminal)
- Template: `~/.config/ghostty/config.template`
- Output: `~/.config/ghostty/config`

### 6. Additional Features

#### Battery Notifications (`battery-notify.sh`)
- Monitors battery level
- Sends critical notifications at 10% and 20%
- Logs to `~/.cache/battery-notify.log`

#### Screenshot Scripts
- `screenshot_full`: Full screen capture
- `screenshot_area`: Area selection capture
- `screenshot`: Selection to clipboard

#### Keyboard RGB Control
- Uses `rogauracore` to set keyboard color
- Sets to `color4` (accent color)
- Requires proper udev rules

#### Firefox Integration
- `pywalfox update` updates Firefox theme
- Integrates with Pywal color scheme

### 7. File Structure

```
~/.config/hypr/
├── hyprland.conf          # Main Hyprland config
├── monitors.conf          # Monitor configuration
├── workspaces.conf        # Workspace assignments
├── scripts/
│   ├── wallpaper.sh       # Main theme switcher
│   ├── wallpaper-select.sh # GUI wallpaper selector
│   ├── apply_wal_outputs.sh # Color distribution
│   ├── battery-notify.sh  # Battery monitoring
│   ├── screenshot_full    # Full screenshot
│   ├── screenshot_area    # Area screenshot
│   └── screenshot         # Selection screenshot
└── THEME_SYSTEM.md       # This documentation

~/.cache/wal/
├── colors.sh             # Pywal color variables
├── colors-*.json         # JSON color formats
└── wallpaper             # Current wallpaper path

~/.config/
├── waybar/
│   ├── style.css.template
│   └── style.css
├── swaync/
│   ├── style.css.template
│   └── style.css
├── wlogout/
│   ├── style.css.template
│   ├── style.css
│   └── icons/
├── swaylock/
│   ├── config.template
│   └── config
├── ghostty/
│   ├── config.template
│   └── config
├── rofi/
│   ├── wallpaper.rasi.template
│   ├── wallpaper.rasi
│   └── colors.rasi
└── eww/
    ├── eww.scss.template
    └── eww.scss
```

### 8. Usage Patterns

#### Manual Theme Switching
```bash
# Random wallpaper
~/.config/hypr/scripts/wallpaper.sh

# Specific wallpaper
~/.config/hypr/scripts/wallpaper.sh /path/to/wallpaper.jpg

# GUI selection
~/.config/hypr/scripts/wallpaper-select.sh
```

#### Keybind Access
- `SUPER + W`: Random wallpaper
- `SUPER + SHIFT + W`: Wallpaper selector

#### Automatic Integration
- Scripts are called from Hyprland autostart
- Services auto-reload when colors change
- Battery notifications run continuously

### 9. Troubleshooting

#### Common Issues
1. **Colors not updating**: Check if `~/.cache/wal/colors.sh` exists
2. **Services not reloading**: Verify service processes are running
3. **Template errors**: Ensure all template files exist
4. **Permission issues**: Check script executability

#### Debug Mode
- Add `set -x` to scripts for verbose output
- Check log files in `~/.cache/`
- Verify Pywal installation and configuration

### 10. Dependencies

#### Required Packages
- `pywal` - Color generation
- `swww` - Wallpaper management
- `waybar` - Status bar
- `swaync` - Notifications
- `eww` - Widgets
- `rofi` - Application launcher
- `swaylock` - Screen lock
- `wlogout` - Logout menu
- `ghostty` - Terminal
- `rogauracore` - Keyboard RGB
- `pywalfox` - Firefox integration

#### Optional Packages
- `zed-theme-wal` - Zed editor theme
- `grimblast` - Screenshot tool
- `slurp` - Selection tool
- `wl-copy` - Clipboard tool

This system provides a complete, automated theme switching solution that maintains consistency across all desktop components while allowing for easy customization and extension.
