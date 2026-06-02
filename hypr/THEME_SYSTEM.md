# Hyprland + Pywal Theme System

## Overview
This setup uses Pywal colors from the active wallpaper or selected static theme and distributes them across the desktop components that are currently in use: Hyprland, Waybar, Rofi, Mako, Swaylock, Kitty, Ghostty, QuickShell, and Zed.

Legacy logout-menu and widget-panel components are intentionally not part of the active theme pipeline.

## Main Scripts

### `wallpaper.sh`
- Location: `~/.config/hypr/scripts/wallpaper.sh`
- Accepts an optional wallpaper path.
- Randomly selects from `~/Pictures/wallpapers/` when no path is given.
- Runs `wal -i` and writes `~/.cache/wal/wallpaper`.
- Starts the wallpaper transition with `awww`.
- Calls `apply_wal_outputs.sh` to regenerate themed outputs.

### `apply_wal_outputs.sh`
- Location: `~/.config/hypr/scripts/apply_wal_outputs.sh`
- Sources `~/.cache/wal/colors.sh`, falling back to `colors.json`.
- Converts hex colors to RGB for CSS/config templates.
- Generates or updates:
  - `~/.config/waybar/style.css`
  - `~/.config/mako/config`
  - `~/.config/swaylock/config`
  - `~/.config/rofi/colors.rasi`
  - `~/.config/rofi/wallpaper.rasi`
  - `~/.config/kitty/kitty.conf`
  - `~/.config/ghostty/config` when its template exists
  - `~/.config/quickshell/theme/Wal.qml`
  - `~/.config/zed/themes/wal-system.json`
- Reloads running services where supported:
  - Waybar: `killall -SIGUSR2 waybar`
  - Mako: `makoctl reload`
  - Kitty: `killall -SIGUSR1 kitty`
  - Ghostty: D-Bus reload when available
- Applies live Hyprland and Mango border colors when those compositors are reachable.

### `theme-apply.sh`
- Location: `~/.config/hypr/scripts/theme-apply.sh`
- Applies static themes from `~/.config/hypr/themes/<theme>/colors.sh`.
- Uses the same active outputs as `apply_wal_outputs.sh`.
- Preserves a selected wallpaper passed through the `wallpaper` environment variable.

### Selectors
- `wallpaper-select.sh` opens a Rofi thumbnail grid for images in `~/Pictures/wallpapers/`.
- `theme-select.sh` opens a Rofi thumbnail grid for static themes and theme backgrounds.
- Both selectors keep image previews while returning full image paths for safer duplicate-filename handling.

## Keybinds
- `SUPER + W`: random wallpaper/theme refresh.
- `SUPER + SHIFT + W`: wallpaper selector.
- `SUPER + SHIFT + T`: static theme selector.
- `SUPER + SHIFT + O`: lock screen with `swaylock --config ~/.config/swaylock/config`.
- `SUPER + N`: toggle Mako do-not-disturb with `~/.config/mako/toggle-dnd.sh`.

## Templates
- Waybar: `~/.config/waybar/style.css.template -> ~/.config/waybar/style.css`
- Mako: `~/.config/mako/config.template -> ~/.config/mako/config`
- Swaylock: `~/.config/swaylock/config.template -> ~/.config/swaylock/config`
- Rofi wallpaper picker: `~/.config/rofi/wallpaper.rasi.template -> ~/.config/rofi/wallpaper.rasi`
- Kitty: `~/.config/kitty/kitty.conf.template -> ~/.config/kitty/kitty.conf`
- Ghostty: `~/.config/ghostty/config.template -> ~/.config/ghostty/config`

Rofi launcher styling is static in `~/.config/rofi/pywal-theme.rasi`; its colors come from generated `~/.config/rofi/colors.rasi`.

## Generated Color Variables
- `color0` through `color15`: hex colors.
- `color0_rgb` through `color15_rgb`: `R,G,B` values.
- `wallpaper`: current wallpaper path.
- `waybar_background`: darkest available palette color for the Waybar background.

## File Layout

```text
~/.config/hypr/
├── hyprland.lua
├── scripts/
│   ├── wallpaper.sh
│   ├── wallpaper-select.sh
│   ├── theme-select.sh
│   ├── theme-apply.sh
│   └── apply_wal_outputs.sh
└── THEME_SYSTEM.md

~/.config/
├── waybar/
│   ├── style.css.template
│   └── style.css
├── mako/
│   ├── config.template
│   ├── config
│   └── toggle-dnd.sh
├── swaylock/
│   ├── config.template
│   └── config
├── kitty/
│   ├── kitty.conf.template
│   └── kitty.conf
└── rofi/
    ├── config.rasi
    ├── pywal-theme.rasi
    ├── wallpaper.rasi.template
    ├── wallpaper.rasi
    └── colors.rasi
```

## Dependencies
- `wal` / Pywal-compatible color generator
- `awww`
- `waybar`
- `mako`
- `rofi`
- `swaylock`
- `kitty`
- `envsubst`
- `grim`, `slurp`, `wl-copy` for screenshot workflows

Optional integrations include Ghostty, QuickShell, Zed theme generation, and ASUS keyboard color control.
