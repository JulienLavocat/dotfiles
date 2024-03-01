# Base 64 decode a file
function b64dec() {
	echo $1 | base64 --decode
}

# Base 64 encode a file
function b64enc() {
	echo $1 | base64
}

# Kill a process runing on the specified port
# @usage killonport [PORT]
function killonport() {
  sudo kill -9 `sudo lsof -t -i:$1`
}

# Scale a deployment to a specified number of replica
# @usage scale [namespace] [deployment] [replicas]
function scale() {
  kubectl scale deployment/$2 --replicas=$3 -n $1
}

# Open a repository's origin
# @usage openorigin
function openorigin() {
  pbcopy $(git remote get-url origin)
}

# Forward ports from namespace
# @usage fwd [namespace]
function fwd() {
  sudo kubefwd svc -n $1 -c ~/.kube/config
}

