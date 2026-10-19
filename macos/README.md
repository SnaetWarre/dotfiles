# Mac setup

Turns a fresh MacBook into the same setup as the Hyprland laptop: AeroSpace for tiling, Tinycast as the launcher, kitty, the same zsh, CLI tools, editors, T3 Code, and the Claude Code / Codex / T3 settings.

## Moving over

1. On the Linux laptop, pack the settings that aren't in this repo:

   ```bash
   ~/.config/macos/export-from-linux.sh
   ```

   This writes `~/mac-migration.tar.gz`. It holds shell history, Claude Code skills and settings, Codex settings, and T3 Code settings. It has no passwords or logins, but keep it off GitHub anyway.

2. Send that file to the Mac with LocalSend or a USB stick, and put it in the Mac's home folder.

3. On the Mac, open Terminal and run:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SnaetWarre/dotfiles/master/macos/install.sh)"
   ```

   It asks for your Mac password (Homebrew), a work email for git, and a GitHub login in the browser. Everything else runs on its own. You can run it again any time and it skips what's already done.

4. Finish the four manual steps it prints at the end (permissions, Tinycast hotkeys, one logout, sign-ins).

## What goes where

| Linux | Mac |
|---|---|
| Hyprland | AeroSpace (`aerospace/aerospace.toml`) |
| Hyprland borders | JankyBorders, started by AeroSpace |
| tofi, cliphist | Tinycast |
| kitty + pywal colors | kitty + `kitty/macos.conf` with today's colors frozen in `kitty/macos-colors.conf` |
| paru / pacman | Homebrew (`macos/Brewfile`), `update` runs `brew upgrade` |
| Docker service | OrbStack, `dockerstart` runs `orb start` |
| `caps:escape` | `capslock-escape.plist`, a login item |
| Dolphin | Finder |

## Shortcuts

Cmd is Super. Most binds are the same as on Linux:

| Keys | Does |
|---|---|
| Cmd+Enter | kitty |
| Cmd+B | Helium |
| Cmd+E | Finder |
| Cmd+Q | close window (quits the app if it was the last one) |
| Cmd+1…0 | go to workspace (press again to jump back) |
| Cmd+Shift+1…0 | send window to workspace |
| Cmd+Ctrl+1…0 | send window and follow it |
| Cmd+Shift+H/J/K/L | move window |
| Cmd+Ctrl+Shift+H/J/K/L | resize window |
| Cmd+Shift+F | float / tile |
| Cmd+Space | Tinycast (set in Tinycast) |

These moved, because on a Mac the old key is copy, find, address bar, or another shortcut you use every day:

| Linux | Mac | Why |
|---|---|---|
| Super+H/J/K/L focus | Cmd+Option+H/J/K/L | Cmd+L is the address bar, Cmd+K the command palette |
| Super+F fullscreen | Cmd+Ctrl+F | Cmd+F is find |
| Super+V float | Cmd+Shift+F | Cmd+V is paste |
| Super+C clipboard | Cmd+Shift+V (set in Tinycast) | Cmd+C is copy |
| Super+Shift+E emoji | Cmd+Ctrl+Space | built into macOS |
| Super+Shift+O lock | Cmd+Ctrl+Q | built into macOS |
| Super+Z / Super+A screenshot | Cmd+Ctrl+Shift+4 (to clipboard) | Cmd+Shift+3/4/5 now move windows |
| Super+drag window | Cmd+Ctrl+drag | macOS setting |

Cmd+Enter and Cmd+B are now global, so apps can't use them. That means no Cmd+Enter to send in web forms and no Cmd+B for bold or the VS Code sidebar. If that gets annoying, change those two lines in `aerospace/aerospace.toml`. It reloads on save.

## Not carried over

- Hyprland animations and blur. macOS doesn't allow them.
- Workspace swipe gestures. [SwipeAeroSpace](https://github.com/MediosZ/SwipeAeroSpace) adds them if you want them.
- waybar. The macOS menu bar takes its place. SketchyBar can come later.
- pywal. The terminal keeps today's colors.
- Games, ASUS tools, and the rest of the Linux-only apps.
