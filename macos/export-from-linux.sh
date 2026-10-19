#!/usr/bin/env bash
# Run on the Linux laptop. Packs the personal settings that are not in this
# public repo (AI tool settings, shell history) into ~/mac-migration.tar.gz.
# Move that file to the Mac (LocalSend, USB) and put it in the Mac's home folder
# before running install.sh. No passwords, tokens or logins are included.
set -euo pipefail

out="$HOME/mac-migration.tar.gz"
cd "$HOME"

paths=(
  .zsh_history
  .claude/CLAUDE.md
  .claude/settings.json
  .claude/skills
  .codex/AGENTS.md
  .codex/config.toml
  .codex/rules
  .t3/userdata/settings.json
  .t3/userdata/client-settings.json
  .t3/userdata/desktop-settings.json
  .t3/userdata/keybindings.json
  .t3/userdata/themes
)

existing=()
for p in "${paths[@]}"; do
  [[ -e "$p" ]] && existing+=("$p")
done

tar -czf "$out" "${existing[@]}"
echo "Wrote $out ($(du -h "$out" | cut -f1)) with:"
printf '  %s\n' "${existing[@]}"
