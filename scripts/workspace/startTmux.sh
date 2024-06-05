tmux -f ~/.config/tmux/tmux.conf new-session -d -s ssh -c ~
tmux -f ~/.config/tmux/tmux.conf new-session -d -s omnimed -c ~/git/Omnimed-solutions
tmux new-window -d -c "~/git/Omnimed-solutions/" -n "k9s" "k9s; zsh"
tmux new-window -d -c "~/git/Omnimed-solutions/" -n "</>"
tmux new-window -d -n "git" "cd ~/git/Omnimed-solutions/; lazygit; zsh"

# Use this to connect whenever you want 
tmux attach -t omnimed

