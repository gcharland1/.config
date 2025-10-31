tmux -f ~/.config/tmux/tmux.conf new-session -d -s "ssh" -c "~"
tmux set status-style "bg=colour52"

tmux -f ~/.config/tmux/tmux.conf new-session -d -s "omnimed"
tmux new-window -n "</>"
tmux send-keys "cd ~/git/Omnimed-solutions/ && clear" Enter

tmux new-window
tmux send-keys "cd ~/git/Omnimed-solutions/ && clear" Enter

tmux attach -t omnimed
