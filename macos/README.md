# Mac setup

Turns a fresh MacBook into the same setup as the Hyprland laptop: AeroSpace for tiling, Tinycast as the launcher, kitty, the same zsh, CLI tools, editors, T3 Code, and the Claude Code / Codex / T3 settings.

## Moving over

1. On the Linux laptop, pack the settings that aren't in this repo. Do this on your last day with the old laptop, so it has your newest history and settings:

   ```bash
   ~/.config/macos/export-from-linux.sh
   ```

   This writes `~/mac-migration.tar.gz`. It holds shell history, Claude Code skills and settings, Codex settings, and T3 Code settings. It has no passwords or logins, but keep it off GitHub anyway, because this repo is public.

2. Send that file to the Mac with LocalSend or a USB stick, and put it in the Mac's home folder.

3. On the Mac, open Terminal and run:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SnaetWarre/dotfiles/master/macos/install.sh)"
   ```

   It asks for your Mac password (Homebrew), a work email for git, and a GitHub login in the browser. Everything else runs on its own. You can run it again any time and it skips what's already done.

4. Do the steps macOS only allows by hand. The script prints them at the end too:
   1. System Settings > Privacy & Security > Accessibility: allow AeroSpace and Tinycast.
   2. Tinycast settings: set the main hotkey to Cmd+Space and clipboard history to Cmd+Shift+V.
   3. Log out and back in once, for the display and Spotlight settings.
   4. Open kitty and check the font and colors. Sign in to Helium, T3 Code, Claude Code and Codex.

Before you start, ask IT what the company's device management allows. Some companies block apps that control windows (AeroSpace) or remap keys (the Caps Lock login item).

## Not tested yet

This was written on the Linux laptop before the Mac arrived, so nothing has run on a real Mac yet. Checked on Linux: the AeroSpace config file is valid, kitty reads the Mac settings, stow links the right files, and the settings bundle builds and unpacks. Watch these on the first run:

- AeroSpace shortcuts on the Belgian keyboard. The config points Q, A, Z, W and M at their AZERTY keys. If Cmd+Q or Cmd+number hits the wrong key, fix the `key-mapping` block in `aerospace/aerospace.toml`.
- Spotlight's Cmd+Space being turned off. If it still opens, turn it off by hand in System Settings > Keyboard > Keyboard Shortcuts > Spotlight.
- Tinycast's `brew trust --tap` step. If brew complains, follow the install steps on Tinycast's GitHub page.

## Why these choices

- **macOS, not Linux.** Asahi Linux only runs on M1 and M2 Macs. An M5 won't be supported for years, if ever.
- **AeroSpace, not yabai.** yabai's best features need macOS security turned off, which a work laptop usually won't allow. AeroSpace works without that.
- **Tinycast, not Raycast.** Tinycast is small, free, open source, and needs no account. Raycast is still an option if Tinycast falls short.
- **Cmd as Super.** It's in the same spot as Super on the old laptop, so muscle memory carries over. The price is that some binds had to move (see below).
- **OrbStack, not Docker Desktop.** It's lighter and runs the same Docker commands.
- **nvm and rustup from their own installers.** That keeps `~/.nvm` and `~/.cargo` in the same place as on Linux, so `.zshrc` needs no changes.
- **Personal settings in a separate file.** This repo is public, so anything personal travels by LocalSend or USB instead.

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
