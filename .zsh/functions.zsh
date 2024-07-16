# Kill a process runing on the specified port
# @usage killonport [PORT]
function killonport() {
  sudo kill -9 `sudo lsof -t -i:$1`
}
