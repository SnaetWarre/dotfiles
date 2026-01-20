#!/usr/bin/env bash

# This script implements the "gross hack" for multi-byte UTF-8 AZERTY characters in tmux.
# It uses the repeat-key (-r) behavior to handle the two bytes of UTF-8 characters.

# é (c3 a9) -> select-pane -t 2
tmux bind-key -r $(printf '\303') display 'AZERTY-Hack'
tmux bind-key -r $(printf '\251') select-pane -t 2

# è (c3 a8) -> select-pane -t 7
tmux bind-key -r $(printf '\250') select-pane -t 7

# ç (c3 a7) -> select-pane -t 9
tmux bind-key -r $(printf '\247') select-pane -t 9

# à (c3 a0) -> select-pane -t 0
tmux bind-key -r $(printf '\240') select-pane -t 0

# § (c2 a7) -> select-pane -t 6
tmux bind-key -r $(printf '\302') display 'AZERTY-Hack'
# Note: a7 is shared with ç, but since the first byte (c2 vs c3) is different, 
# tmux stays in the repeat mode of the specific prefix byte.
tmux bind-key -r $(printf '\247') select-pane -t 6

# Single byte characters (Standard bindings)
tmux bind-key "&" select-pane -t 1
tmux bind-key "\"" select-pane -t 3
tmux bind-key "'" select-pane -t 4
tmux bind-key "(" select-pane -t 5
tmux bind-key "!" select-pane -t 8
