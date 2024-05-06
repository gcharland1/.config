tmux -f ~/.config/tmux/tmux.conf new-session -d -s ssh -c ~
tmux -f ~/.config/tmux/tmux.conf new-session -d -s omnimed -c ~/git/Omnimed-solutions
tmux new-window -t omnimed -d "k9s" \; new-window -t omnimed "cd ~/git/Omnimed-solutions/; lazygit"

# Use this to connect whenever you want 
tmux attach -t omnimed

