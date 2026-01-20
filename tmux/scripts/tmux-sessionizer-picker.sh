#!/usr/bin/env bash

# This script runs INSIDE the popup - it only does selection and session creation
# It does NOT call switch-client (that happens in the wrapper after popup closes)

TMUX_SESSION_FILE="/tmp/tmux-sessionizer-target"

# Deep search paths
SEARCH_PATHS=(
    "$HOME/Documents"
    "$HOME/.config"
)

selected=$(
    (
        # 1. Find directories containing .git or package.json up to 8 levels deep
        fd -H -d 8 '^\.git$|package\.json$' "${SEARCH_PATHS[@]}" -E 'node_modules' 2>/dev/null | xargs -I{} dirname {};
        
        # 2. Direct subdirs of Documents (level 1)
        fd -t d -d 1 . "$HOME/Documents" 2>/dev/null;
        
        # 3. Explicitly common roots
        fd -t d -d 1 . "$HOME/Documents/gfprojects" 2>/dev/null;
        fd -t d -d 1 . "$HOME/Documents/howest" 2>/dev/null;

        # 4. Dotfiles
        echo "$HOME/.config";
    ) | \
    sort -u | \
    fzf --prompt="Projects > " \
        --height=100% \
        --layout=reverse \
        --border \
        --no-multi \
        --preview '
            if [ -f {}/README.md ]; then
                head -30 {}/README.md
            else
                ls -F --color=always {} 2>/dev/null | head -20
            fi
        '
)

# User cancelled - exit without writing file
if [[ -z $selected ]]; then
    exit 0
fi

# Generate session name
selected_name=$(basename "$selected" | tr . _)

# Create session if it doesn't exist
if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    # Create new session detached
    tmux new-session -ds "$selected_name" -c "$selected"
    
    # Window 1: Editor (nvim)
    tmux rename-window -t "$selected_name:1" "editor"
    tmux send-keys -t "$selected_name:1" "nvim" Enter
    
    # Window 2: Terminal for dev servers
    tmux new-window -t "$selected_name" -n "terminal" -c "$selected"
    
    # Focus back to editor window
    tmux select-window -t "$selected_name:1"
fi

# Write session name to temp file - wrapper script will read this
echo "$selected_name" > "$TMUX_SESSION_FILE"
