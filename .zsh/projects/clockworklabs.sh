function update-cloud-julien() {
    cargo build --release
    cargo controldb build

    scp /home/julien/clockworklabs/spacetimedbprivate/target/wasm32-unknown-unknown/release-wasm/spacetime_control.wasm root@stdb:/stdb
    scp /home/julien/clockworklabs/spacetimedbprivate/target/release/spacetimedb-cloud root@stdb:/stdb

    echo "Build and upload complete. Now run the following commands on the server:"
    echo "service spacetimedb restart"
}

function cl-login-local() {
    spacetime login --auth-host http://localhost:3000
}

function cl-login-stg() {
    spacetime login --auth-host https://staging.spacetimedb.com
}

function cl-login-prod() {
    spacetime login
}

function update_image_tag() {
    set -e

    local env=$1
    local app=$2
    local sha=$3

    # Validate args
    if [[ -z "$env" || -z "$app" || -z "$sha" ]]; then
        echo "Usage: update_image_tag <env> <app> <sha>"
        echo "  env: stg | prod"
        echo "  app: web-client | spacetimeauth"
        return 1
    fi

    if [[ "$env" != "stg" && "$env" != "prod" ]]; then
        echo "Error: env must be 'stg' or 'prod'"
        return 1
    fi

    local file=~/clockworklabs/kubernetes/applications/clusters/spacetimedb-${env}/charts/${app}/values.yaml

    if [[ ! -f "$file" ]]; then
        echo "Error: file not found: $file"
        return 1
    fi

    # Extract the image name prefix (everything before the tag after the last colon)
    local current_image=$(grep -E '^\s*image:' "$file" | head -1 | sed 's/.*image:[[:space:]]*//' | tr -d '"')
    local image_base=$(echo "$current_image" | sed 's/:.*$//')

    local new_tag="commit-${sha}"
    local new_image="${image_base}:${new_tag}"

    # Replace the image line in place
    # Replace the image line in place
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|image:.*|image: \"${new_image}\"|" "$file"
    else
        sed -i "s|image:.*|image: \"${new_image}\"|" "$file"
    fi

    cd ~/clockworklabs/kubernetes

    echo "Updated $file"
    echo "  $current_image → $new_image"
}
