tmux -f ~/.config/tmux/tmux.conf new-session -d -s "ssh" -c "~"
tmux -f ~/.config/tmux/tmux.conf new-session -d -s "omnimed" -c "~/git/Omnimed-solutions"
tmux new-window -d -n "</>"
tmux new-window -d -n "git" "cd ~/git/Omnimed-solutions/; lazygit; zsh"

tmux attach -t omnimed
