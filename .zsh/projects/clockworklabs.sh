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

# Build spacetimedb-cloud at a given git tag and push it to my registry.
# Usage: cl-docker-private <git-tag> [extra docker buildx args...]
cl-docker-private() (
  emulate -L zsh
  setopt err_return pipe_fail

  local repo=/home/julien/clockworklabs/spacetimedbprivate
  local image="${CL_DOCKER_IMAGE:-git.jlavocat.eu/julienlavocat/spacetimedb-cloud}"
  local platform="${CL_DOCKER_PLATFORM:-linux/amd64}"

  local tag=$1
  if [[ -z $tag ]]; then
    print -u2 "usage: cl-docker-private <git-tag> [extra docker buildx args...]"
    return 2
  fi
  shift

  cd $repo

  # Checking out the tag would clobber (or be blocked by) local changes.
  if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    print -u2 "cl-docker-private: working tree has uncommitted changes; commit or stash first"
    return 1
  fi


  # Only fetch the requested tag, and only if we don't have it yet. A blanket
  # `git fetch --tags` fails when any unrelated local tag diverges from origin.
  if ! git rev-parse --quiet --verify "refs/tags/$tag^{commit}" >/dev/null; then
    git fetch origin "refs/tags/$tag:refs/tags/$tag" || {
      print -u2 "cl-docker-private: no such tag: $tag"
      return 1
    }
  fi

  # Remember where we were (branch name, or sha if detached) to restore afterwards.
  local prev
  prev=$(git symbolic-ref --quiet --short HEAD || git rev-parse HEAD)

  {
    git checkout --quiet "refs/tags/$tag"
    git submodule update --init --recursive

    docker buildx build \
      -f private/crates/cloud/Dockerfile \
      -t "$image:$tag" \
      --platform "$platform" \
      --push \
      "$@" \
      .
    print "pushed $image:$tag"
  } always {
    git checkout --quiet "$prev" && git submodule update --init --recursive
  }
)
