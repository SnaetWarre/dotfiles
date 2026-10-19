#!/usr/bin/env bash
# One-shot Mac setup. Run on a fresh Mac with:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SnaetWarre/dotfiles/master/macos/install.sh)"
# Safe to run again: every step skips what is already done.
set -euo pipefail

repo_https="https://github.com/SnaetWarre/dotfiles.git"
repo_ssh="git@github.com:SnaetWarre/dotfiles.git"
config="$HOME/.config"
migration="$HOME/mac-migration.tar.gz"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

[[ "$(uname)" == Darwin ]] || { echo "This script is for macOS." >&2; exit 1; }

step "Homebrew"
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

step "Dotfiles into ~/.config"
if [[ ! -d "$config/.git" ]]; then
  # ~/.config usually exists already (gh, Homebrew), so clone elsewhere and move .git in.
  tmp="$(mktemp -d)"
  git clone "$repo_https" "$tmp/dotfiles"
  mkdir -p "$config"
  mv "$tmp/dotfiles/.git" "$config/.git"
  git -C "$config" reset --hard -q
  rm -rf "$tmp"
fi

step "Apps and CLI tools (Brewfile)"
brew trust --tap abue-ammar/tinycast 2>/dev/null || true
brew bundle --file "$config/macos/Brewfile" || echo "Some packages failed. Run this script again later to retry them."

step "Shell files (stow home/ into ~)"
for f in $(ls -A "$config/home"); do
  if [[ -e "$HOME/$f" && ! -L "$HOME/$f" ]]; then
    mv "$HOME/$f" "$HOME/$f.before-dotfiles"
    echo "Moved existing ~/$f to ~/$f.before-dotfiles"
  fi
done
stow -d "$config" -t "$HOME" home

step "Node (nvm) and Rust (rustup)"
if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | PROFILE=/dev/null bash
fi
if [[ ! -d "$HOME/.nvm/versions/node" ]]; then
  set +u # nvm.sh reads unset variables
  # shellcheck disable=SC1091
  source "$HOME/.nvm/nvm.sh"
  nvm install --lts
  set -u
fi
if [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

step "Personal settings from the Linux laptop"
if [[ -f "$migration" ]]; then
  tmp="$(mktemp -d)"
  tar -xzf "$migration" -C "$tmp"
  # Keep any history the Mac already has, then add the Linux history.
  if [[ -f "$tmp/.zsh_history" ]]; then
    cat "$tmp/.zsh_history" >> "$HOME/.zsh_history"
    rm "$tmp/.zsh_history"
  fi
  rsync -a "$tmp/" "$HOME/"
  rm -rf "$tmp"
  echo "Imported Claude Code, Codex and T3 Code settings and shell history."
else
  echo "No $migration found, skipping. Run macos/export-from-linux.sh on the old laptop first."
fi

step "Git identity for work"
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  read -r -p "Work email for git commits (leave empty to keep the student email): " work_email < /dev/tty || true
  if [[ -n "${work_email:-}" ]]; then
    printf '[user]\n\temail = %s\n' "$work_email" > "$HOME/.gitconfig.local"
  fi
fi

step "macOS settings"
bash "$config/macos/defaults.sh"

step "Caps Lock as Escape"
agent="$HOME/Library/LaunchAgents/local.capslock-escape.plist"
mkdir -p "$(dirname "$agent")"
cp "$config/macos/capslock-escape.plist" "$agent"
launchctl bootout "gui/$(id -u)" "$agent" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$agent"

step "GitHub login (also makes and uploads an SSH key)"
if ! gh auth status >/dev/null 2>&1; then
  gh auth login --git-protocol ssh --web < /dev/tty
fi
git -C "$config" remote set-url origin "$repo_ssh"

step "Start AeroSpace and Tinycast"
open -a AeroSpace
open -a Tinycast

cat <<'EOF'

Done. A few things macOS only lets you do by hand:

  1. System Settings > Privacy & Security > Accessibility: allow AeroSpace and Tinycast.
  2. Tinycast settings: set the main hotkey to Cmd+Space, clipboard history to Cmd+Shift+V.
  3. Log out and back in once (for the display and Spotlight settings).
  4. Open kitty, check the font and colors, and sign in to Helium, T3 Code, Claude Code and Codex.

Shortcut changes from Hyprland are listed in ~/.config/macos/README.md.
EOF
