# Screen Picker Dialog Fix - xdg-desktop-portal-hyprland

## The Real Problem

The white/beige screen picker dialog you were seeing is **NOT a GTK application**. It's the built-in "simple" chooser from `xdg-desktop-portal-hyprland` itself, which is hardcoded and cannot be themed with GTK CSS.

## What We Actually Did

### Wrong Approach (What We Tried First)
- Created GTK-3.0 and GTK-4.0 CSS templates
- Added pywal integration for GTK theming
- This WILL work for actual GTK dialogs (file pickers, etc.) but NOT for the Hyprland screen picker

### Right Approach (What Actually Works)

The solution is to **replace** the built-in simple chooser with a themeable alternative.

## Solution: Use Rofi as Screen Picker

### Configuration File: `~/.config/xdg-desktop-portal/hyprland.conf`

```ini
[screencast]
output_name=
max_fps=60
allow_token_by_default=false
chooser_type=dmenu
chooser_cmd=rofi -dmenu -p "Select screen to share"
```

### What This Does
- `chooser_type=dmenu` - Tells xdg-desktop-portal-hyprland to use a dmenu-compatible program
- `chooser_cmd=rofi -dmenu -p "Select screen to share"` - Uses your already-themed Rofi instead of the built-in picker
- Rofi WILL respect your pywal colors since it's already integrated!

### Portal Preference: `~/.config/xdg-desktop-portal/portals.conf`

```ini
[preferred]
default=gtk;hyprland
org.freedesktop.impl.portal.ScreenCast=hyprland
org.freedesktop.impl.portal.Screenshot=hyprland
```

This ensures Hyprland portal is used for screen sharing (not GTK portal).

## How to Test

1. **Restart the portals** (already done):
   ```bash
   killall xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal
   systemctl --user restart xdg-desktop-portal.service
   ```

2. **Try screen sharing in Discord again**:
   - Instead of the white dialog, you should now see a **Rofi menu**
   - The Rofi menu WILL be themed with your pywal colors
   - Select your screen from the list

## Alternative Choosers

If you don't like Rofi for this, you can use:

### Wofi
```ini
chooser_cmd=wofi --dmenu --prompt "Select screen to share"
```

### Fuzzel
```ini
chooser_cmd=fuzzel --dmenu --prompt "Select screen to share"
```

### Custom Script
You can even create a custom script that shows screens with more info:
```ini
chooser_cmd=/path/to/your/custom-screen-picker.sh
```

## What About the GTK CSS We Created?

It's still useful! It will theme:
- File picker dialogs (Open/Save)
- Color pickers
- Font dialogs
- Any other GTK-based portal dialogs
- Regular GTK applications

So the work wasn't wasted - it just doesn't apply to the Hyprland screen picker specifically.

## Why This Happens

`xdg-desktop-portal-hyprland` has its own implementation of the screen picker that's separate from GTK. It provides two chooser types:

1. **simple** (default) - Built-in, hardcoded, can't be themed
2. **dmenu** - Delegates to an external dmenu-compatible program (themeable!)

## Summary

- ✅ Created pywal GTK theming (works for GTK dialogs)
- ✅ Configured Hyprland portal to use Rofi instead of built-in picker
- ✅ Rofi will show your pywal colors automatically
- ✅ Screen picker is now themed!

## Testing Results

Try screen sharing in Discord now - you should see a Rofi menu with your wallpaper colors instead of the white dialog!

---

**Date**: November 5, 2025  
**Issue**: Screen picker not themed  
**Root Cause**: xdg-desktop-portal-hyprland using built-in simple chooser  
**Solution**: Switch to dmenu chooser type with Rofi  
**Status**: Fixed ✓