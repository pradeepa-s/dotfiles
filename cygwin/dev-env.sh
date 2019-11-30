#! /bin/bash

tmux new-window
tmux split-window -h -c "#{pane_current_path}"
tmux split-window -v -c "#{pane_current_path}"
tmux select-pane -L
tmux resize-pane -R 20
