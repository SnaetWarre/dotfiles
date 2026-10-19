# Mac-only shell settings. Sourced at the end of home/.zshrc on macOS.

# Keep CLI tools (lazygit, etc.) reading ~/.config instead of ~/Library.
export XDG_CONFIG_HOME="$HOME/.config"

alias update="brew update && brew upgrade"
alias yay="brew"
alias off="sudo shutdown -h now"
alias kys="off"
alias houjekankerbek="off"
alias poweroff="off"

# OrbStack runs Docker on the Mac; there is no systemd service to start.
alias dockerstart="orb start"
alias dockerstop="orb stop"
alias dockerstatus="orb status"

# Linux clipboard muscle memory
alias wl-copy="pbcopy"
alias wl-paste="pbpaste"
