# GTK + Pywal Integration Documentation

## Overview
This document describes the integration of GTK theming with the Pywal color system for dynamic theming of GTK applications, specifically targeting the xdg-desktop-portal screen picker dialog that appears when livestreaming/screen sharing.

## Problem Statement
The xdg-desktop-portal screen picker dialog (shown when selecting screens to share in Discord, OBS, etc.) was displaying with a default white/light theme instead of respecting the system's Breeze-Dark theme or integrating with the pywal color scheme.

## Solution
A two-layer approach was implemented:
1. **Base Theme**: Force Breeze-Dark as the GTK theme via settings.ini
2. **Color Overrides**: Use pywal-generated colors to override specific UI elements with CSS

## Files Created/Modified

### New Template Files

#### `.config/gtk-3.0/gtk.css.template`
- Pywal color override template for GTK-3 applications
- Integrates with Breeze-Dark base theme
- Targets xdg-desktop-portal screen picker specifically
- Uses pywal color variables: `${color0_rgb}` through `${color8_rgb}`

#### `.config/gtk-4.0/gtk.css.template`
- Pywal color override template for GTK-4 applications
- Similar to GTK-3 template but adapted for GTK-4 API
- Uses GTK-4 color naming conventions (e.g., `window_bg_color`, `accent_bg_color`)

### Generated Files (Auto-created by apply_wal_outputs.sh)

#### `.config/gtk-3.0/gtk.css`
- Generated from template with current pywal colors
- Overrides Breeze-Dark elements with wallpaper-derived colors

#### `.config/gtk-4.0/gtk.css`
- Generated from template with current pywal colors
- GTK-4 version of color overrides

### Existing Files (Already Present)

#### `.config/gtk-3.0/settings.ini`
- Already configured with `gtk-theme-name=Breeze-Dark`
- Ensures Breeze-Dark is the base theme

#### `.config/gtk-4.0/settings.ini`
- Already configured with `gtk-theme-name=Breeze-Dark`
- GTK-4 base theme configuration

### Modified Script

#### `.config/hypr/scripts/apply_wal_outputs.sh`
- Added GTK-3.0 processing section (after Ghostty, before eww)
- Added GTK-4.0 processing section
- Fixed `write_if_changed` return code handling with `|| true`
- Added timing logs for GTK processing

## Color Mapping

### Pywal Colors Used
- `color0` / `color0_rgb` - Background (dark)
- `color1` / `color1_rgb` - Alternate background
- `color4` / `color4_rgb` - Accent/selection color (primary highlight)
- `color7` / `color7_rgb` - Foreground text color
- `color8` / `color8_rgb` - Borders, secondary elements

### UI Element Styling

| UI Element | Background | Foreground | Accent |
|------------|------------|------------|--------|
| Window | `color0` (95% opacity) | `color7` | - |
| Header bar | `color0` (98% opacity) | `color7` | `color4` border |
| Tabs (unselected) | `color8` (20% opacity) | `color7` (70% opacity) | - |
| Tabs (selected) | `color4` (90% opacity) | `color0` | `color4` border |
| List rows | `color1` (40% opacity) | `color7` | - |
| List rows (selected) | `color4` (85% opacity) | `color0` | `color4` glow |
| Buttons | `color1` (60% opacity) | `color7` | - |
| Buttons (hover) | `color8` (50% opacity) | `color7` | `color4` border |
| Suggested buttons | `color4` (85% opacity) | `color0` | - |

## Design Aesthetic

The styling matches the existing pywal-themed components (waybar, rofi, swaync):
- **Rounded corners**: 6-12px border-radius for modern look
- **Transparency**: rgba() colors with 85-98% opacity
- **Smooth transitions**: 150-200ms ease transitions
- **Accent highlights**: color4 (wallpaper accent) for selections and focus
- **Shadow effects**: Subtle box-shadows for depth
- **Transform effects**: Slight hover lifts (translateY)

## Integration with Existing Theme System

### Workflow
1. User runs `~/.config/hypr/scripts/wallpaper.sh` (or uses SUPER+W keybind)
2. Pywal generates colors from wallpaper → `~/.cache/wal/colors.sh`
3. `apply_wal_outputs.sh` is called
4. Script processes all templates including new GTK templates:
   - Sources colors from `~/.cache/wal/colors.sh`
   - Converts hex colors to RGB format
   - Uses `envsubst` to replace variables in templates
   - Generates final CSS files in gtk-3.0/ and gtk-4.0/
5. GTK applications automatically pick up new CSS on next launch
6. xdg-desktop-portal respects new styling when opened

### No Service Restart Required
Unlike waybar or swaync, GTK CSS changes are picked up automatically by GTK applications when they start. The xdg-desktop-portal screen picker will use the new theme the next time it's opened.

## Testing

### How to Test
1. Run the wallpaper script to apply current colors:
   ```bash
   ~/.config/hypr/scripts/wallpaper.sh
   ```

2. Open an application that triggers the screen picker:
   - Discord: Try to stream/share screen
   - Browser: Try to share screen in a video call
   - OBS: Screen capture source

3. Verify the screen picker dialog shows:
   - Dark background (not white)
   - Wallpaper-derived accent colors
   - Rounded corners and modern styling
   - Smooth hover effects

### Verification Commands
```bash
# Check if GTK CSS files were generated
ls -lh ~/.config/gtk-3.0/gtk.css ~/.config/gtk-4.0/gtk.css

# View generated colors (should show RGB values, not template variables)
head -30 ~/.config/gtk-3.0/gtk.css

# Check processing logs
bash ~/.config/hypr/scripts/apply_wal_outputs.sh 2>&1 | grep -i gtk

# Verify timing (should complete in ~20-30ms)
bash ~/.config/hypr/scripts/apply_wal_outputs.sh 2>&1 | grep "gtk.*-css"
```

## Troubleshooting

### Screen picker still shows white/light theme
1. **Check GTK theme settings**:
   ```bash
   gsettings get org.gnome.desktop.interface gtk-theme
   # Should return: 'Breeze-Dark'
   ```

2. **Verify settings.ini exists**:
   ```bash
   cat ~/.config/gtk-3.0/settings.ini
   cat ~/.config/gtk-4.0/settings.ini
   ```

3. **Regenerate CSS**:
   ```bash
   ~/.config/hypr/scripts/apply_wal_outputs.sh
   ```

4. **Restart the portal** (if needed):
   ```bash
   killall xdg-desktop-portal-gtk
   killall xdg-desktop-portal-hyprland
   ```

### Colors not updating
1. **Run wallpaper script**:
   ```bash
   ~/.config/hypr/scripts/wallpaper.sh
   ```

2. **Check if templates exist**:
   ```bash
   ls -l ~/.config/gtk-{3,4}.0/*.template
   ```

3. **Verify pywal colors are loaded**:
   ```bash
   source ~/.cache/wal/colors.sh && echo $color0 $color4 $color7
   ```

### Styling looks wrong
1. **Check for CSS syntax errors**:
   ```bash
   # GTK CSS errors often show in journal
   journalctl --user -xe | grep -i gtk
   ```

2. **Restore from template**:
   ```bash
   ~/.config/hypr/scripts/apply_wal_outputs.sh
   ```

3. **Verify color values**:
   ```bash
   grep "define-color" ~/.config/gtk-3.0/gtk.css
   ```

## Future Enhancements

Potential improvements:
- [ ] Add more GTK application targeting (file pickers, dialogs)
- [ ] Create GTK-2 theme template for legacy apps
- [ ] Add window manager-specific overrides
- [ ] Integrate with Qt theming for consistency
- [ ] Add brightness/contrast adjustment options
- [ ] Create theme preview/test utility

## Technical Details

### envsubst Variables
The following variables are substituted in templates:
- `${color0_rgb}` through `${color8_rgb}` - RGB color values (e.g., "24,25,26")
- Variables are exported in `apply_wal_outputs.sh` before envsubst

### Processing Order
GTK CSS processing occurs in this order within `apply_wal_outputs.sh`:
1. Waybar CSS
2. Swaync CSS
3. Wlogout CSS
4. Swaylock config
5. Rofi themes
6. Ghostty config
7. **GTK-3.0 CSS** ← Added here
8. **GTK-4.0 CSS** ← Added here
9. eww CSS
10. Service restarts
11. Hyprland border colors

### Performance Impact
- GTK-3.0 processing: ~30ms
- GTK-4.0 processing: ~20ms
- Total added time: ~50ms (negligible)
- No runtime performance impact on applications

## Integration Notes

### Breeze-Dark Base Theme
- GTK CSS files **override** Breeze-Dark, not replace it
- Full Breeze theme still loads first
- Our CSS uses `@define-color` to override color variables
- Widget-specific selectors ensure targeted styling

### xdg-desktop-portal Specificity
The CSS specifically targets:
- `window.background` - Main portal window
- `headerbar` - Title bar
- `notebook > header > tabs` - Tab bar (Screen/Window/Region)
- `list`, `listview`, `row` - Screen/window selection lists
- `button`, `checkbutton` - Action buttons

### GTK-3 vs GTK-4 Differences
- **GTK-3**: Uses `notebook` for tabs
- **GTK-4**: Uses `tabbar` and `tab` widgets
- **GTK-3**: Color names use `theme_*` prefix
- **GTK-4**: Color names use descriptive names (e.g., `window_bg_color`)

## References

### Related Files
- Main theme docs: `~/.config/hypr/THEME_SYSTEM.md`
- Wallpaper script: `~/.config/hypr/scripts/wallpaper.sh`
- Color application: `~/.config/hypr/scripts/apply_wal_outputs.sh`

### External Resources
- [GTK CSS Overview](https://docs.gtk.org/gtk3/css-overview.html)
- [Pywal Documentation](https://github.com/dylanaraps/pywal)
- [xdg-desktop-portal](https://github.com/flatpak/xdg-desktop-portal)

## Changelog

### 2025-11-05 - Initial Implementation
- Created GTK-3.0 and GTK-4.0 CSS templates
- Integrated GTK processing into apply_wal_outputs.sh
- Fixed write_if_changed return code handling bug
- Documented full system integration
- Tested with xdg-desktop-portal screen picker

---

**Author**: Assistant AI with user @warre  
**Date**: November 5, 2025  
**Status**: Active ✓  
**Version**: 1.0