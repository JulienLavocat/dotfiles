function cl-web() {
    BASE_PATH=~/clockworklabs/web

    # Run all databases, except the web server
    SERVICES=(pgsql prometheus)
    docker compose -f $BASE_PATH/docker-compose.yml up -d $SERVICES

    tmux rename-window 'nvim-stdb-web'
    tmux send-keys "cd $BASE_PATH/spacetimedb && nvim" Enter

    # Run the web server
    tmux new-window -n 'stdb-web'
    tmux send-keys "cd $BASE_PATH/spacetimedb.com && pnpm dev" Enter

    # Add a new pane to run commands
    tmux split-window
}
