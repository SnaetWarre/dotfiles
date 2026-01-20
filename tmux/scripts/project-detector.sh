#!/usr/bin/env bash

SESSION_NAME=$1
PROJECT_PATH=$2

if [[ -z $SESSION_NAME ]] || [[ -z $PROJECT_PATH ]]; then
    exit 1
fi

# Default layout: One main pane with nvim, one smaller pane for terminal
# Detect project type
if [[ -f "$PROJECT_PATH/package.json" ]]; then
    # Node/JS project
    tmux send-keys -t "$SESSION_NAME:1" "nvim" Enter
    tmux split-window -v -p 30 -t "$SESSION_NAME:1" -c "$PROJECT_PATH"
    tmux send-keys -t "$SESSION_NAME:1.2" "npm run dev || npm start"
    tmux select-pane -t "$SESSION_NAME:1.1"
elif [[ -d "$PROJECT_PATH/.git" ]]; then
    # General Git project
    tmux send-keys -t "$SESSION_NAME:1" "nvim" Enter
    tmux split-window -v -p 30 -t "$SESSION_NAME:1" -c "$PROJECT_PATH"
    tmux select-pane -t "$SESSION_NAME:1.1"
else
    # Fallback
    tmux send-keys -t "$SESSION_NAME:1" "nvim" Enter
    tmux select-pane -t "$SESSION_NAME:1.1"
fi
