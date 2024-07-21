# Kill a process runing on the specified port
# @usage killonport [PORT]
function killonport() {
  sudo lsof -i:$1
  port=$(sudo lsof -t -i:$1)
  sudo kill -9 $port
}
