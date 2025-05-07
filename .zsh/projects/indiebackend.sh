function idb-start() {
    tmux rename-window 'Idb services'
    tmux send-keys 'cd ~/idb/api && yarn start:dev' Enter
    tmux split-window 
    tmux send-keys 'cd ~/idb/sso && yarn start' Enter
    tmux split-window 
    tmux send-keys 'cd rules && air' Enter
    tmux split-window 
    tmux send-keys 'cd notifications && yarn start' Enter
    tmux split-window 
    tmux send-keys 'cd ~/idb/dashboard && yarn start' Enter
}
